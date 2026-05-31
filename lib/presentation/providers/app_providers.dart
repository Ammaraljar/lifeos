import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';
import '../../data/repositories/habits_repository.dart';

// ===== Shared Preferences =====
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// ===== Settings =====
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier(ref.watch(sharedPrefsProvider));
});

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences _p;
  LocaleNotifier(this._p) : super(_p.getString(AppConstants.settingsLanguage) ?? 'ar');
  void toggle() {
    final next = state == 'ar' ? 'en' : 'ar';
    state = next;
    _p.setString(AppConstants.settingsLanguage, next);
  }
  void set(String locale) {
    state = locale;
    _p.setString(AppConstants.settingsLanguage, locale);
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref.watch(sharedPrefsProvider));
});

class DarkModeNotifier extends StateNotifier<bool> {
  final SharedPreferences _p;
  DarkModeNotifier(this._p) : super(_p.getBool(AppConstants.settingsDarkMode) ?? true);
  void toggle() {
    state = !state;
    _p.setBool(AppConstants.settingsDarkMode, state);
  }
}

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String>((ref) {
  return ApiKeyNotifier(ref.watch(sharedPrefsProvider));
});

class ApiKeyNotifier extends StateNotifier<String> {
  final SharedPreferences _p;
  ApiKeyNotifier(this._p) : super(_p.getString(AppConstants.settingsApiKey) ?? '');
  Future<void> save(String key) async {
    state = key;
    await _p.setString(AppConstants.settingsApiKey, key);
  }
}

// ===== Habits =====
final habitsBoxProvider = Provider<Box<HabitModel>>((ref) => Hive.box<HabitModel>(AppConstants.hiveHabitBox));
final logsBoxProvider = Provider<Box<HabitLog>>((ref) => Hive.box<HabitLog>(AppConstants.hiveLogBox));

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<HabitModel>>((ref) {
  return HabitsNotifier(ref.watch(habitsBoxProvider));
});

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  final Box<HabitModel> _box;

  HabitsNotifier(this._box) : super([]) {
    _load();
  }

  Future<void> _load() async {
    if (_box.isEmpty) {
      // First run — seed with default habits
      for (final h in DefaultHabits.all) {
        await _box.put(h.id, h);
      }
    }
    state = _box.values.where((h) => h.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> addHabit(HabitModel h) async {
    await _box.put(h.id, h);
    _refresh();
  }

  Future<void> toggleActive(String id) async {
    final h = _box.get(id);
    if (h != null) {
      h.isActive = !h.isActive;
      await h.save();
      _refresh();
    }
  }

  void _refresh() {
    state = _box.values.where((h) => h.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<HabitModel> byCategory(HabitCategory cat) =>
      state.where((h) => h.category == cat).toList();
}

// ===== Habit Logs =====
final logsProvider = StateNotifierProvider<LogsNotifier, List<HabitLog>>((ref) {
  return LogsNotifier(ref.watch(logsBoxProvider));
});

class LogsNotifier extends StateNotifier<List<HabitLog>> {
  final Box<HabitLog> _box;
  LogsNotifier(this._box) : super(_box.values.toList());
  void _refresh() => state = _box.values.toList();

  Future<void> toggleToday(String habitId, {int? value}) async {
    final today = _todayDate();
    final existing = state.where((l) => l.habitId == habitId && l.isSameDay(today)).firstOrNull;

    if (existing != null) {
      // Toggle off
      await _box.delete(existing.id);
    } else {
      // Toggle on
      final log = HabitLog(habitId: habitId, date: today, completed: true, value: value);
      await _box.put(log.id, log);
    }
    _refresh();
  }

  Future<void> logValue(String habitId, int value) async {
    final today = _todayDate();
    final existing = state.where((l) => l.habitId == habitId && l.isSameDay(today)).firstOrNull;
    if (existing != null) {
      existing.value = value;
      existing.completed = value > 0;
      await existing.save();
    } else {
      final log = HabitLog(habitId: habitId, date: today, completed: value > 0, value: value);
      await _box.put(log.id, log);
    }
    _refresh();
  }

  DateTime _todayDate() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool isCompletedToday(String habitId) {
    final today = DateTime.now();
    return state.any((l) =>
        l.habitId == habitId &&
        l.completed &&
        l.date.year == today.year &&
        l.date.month == today.month &&
        l.date.day == today.day);
  }

  int? todayValue(String habitId) {
    final today = DateTime.now();
    final log = state.where((l) =>
        l.habitId == habitId &&
        l.date.year == today.year &&
        l.date.month == today.month &&
        l.date.day == today.day).firstOrNull;
    return log?.value;
  }

  List<HabitLog> logsFor(String habitId) =>
      state.where((l) => l.habitId == habitId).toList();

  int streakFor(String habitId) =>
      HabitsRepository.calculateStreak(logsFor(habitId));

  double consistencyFor(String habitId, DateTime since) =>
      HabitsRepository.calculateConsistencyRate(logsFor(habitId), since);

  // Today's completion summary
  int completedTodayCount(List<HabitModel> habits) {
    return habits.where((h) => isCompletedToday(h.id)).length;
  }

  // Week stats
  Map<int, int> weekCompletions(List<HabitModel> habits) {
    final result = <int, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final d = DateTime(day.year, day.month, day.day);
      result[6 - i] = habits.where((h) =>
        state.any((l) => l.habitId == h.id && l.completed && l.isSameDay(d))
      ).length;
    }
    return result;
  }

  // Prayer count today
  int prayersToday(List<HabitModel> habits) {
    final prayers = habits.where((h) => h.type == HabitType.prayer).toList();
    return prayers.where((p) => isCompletedToday(p.id)).length;
  }

  // Annual prayer consistency
  double annualPrayerConsistency(List<HabitModel> habits) {
    final prayers = habits.where((h) => h.type == HabitType.prayer).toList();
    if (prayers.isEmpty) return 0;
    final since = DateTime(DateTime.now().year, 1, 1);
    final rates = prayers.map((p) => consistencyFor(p.id, since));
    return rates.reduce((a, b) => a + b) / prayers.length;
  }

  // Annual Quran pages
  int annualQuranPages(List<HabitModel> habits) {
    final quran = habits.where((h) => h.type == HabitType.quran).firstOrNull;
    if (quran == null) return 0;
    final since = DateTime(DateTime.now().year, 1, 1);
    return logsFor(quran.id)
        .where((l) => l.date.isAfter(since) && l.completed)
        .fold(0, (sum, l) => sum + (l.value ?? (l.completed ? 4 : 0)));
  }

  // Annual English hours
  double annualEnglishHours(List<HabitModel> habits) {
    final study = habits.where((h) => h.type == HabitType.study).firstOrNull;
    if (study == null) return 0;
    final since = DateTime(DateTime.now().year, 1, 1);
    final sessions = logsFor(study.id).where((l) => l.date.isAfter(since) && l.completed).length;
    return sessions * 1.5; // 90 min per session
  }
}

// ===== Computed =====
final todayCompletionProvider = Provider<double>((ref) {
  final habits = ref.watch(habitsProvider);
  final logs = ref.watch(logsProvider);
  if (habits.isEmpty) return 0;
  final done = habits.where((h) => logs.any((l) => l.habitId == h.id && l.completed && l.isToday)).length;
  return done / habits.length;
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
