import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../../core/theme/app_theme.dart';

class DefaultHabits {
  static List<HabitModel> get all => [
    // ===== SPIRITUAL =====
    HabitModel(
      nameEn: 'Fajr Prayer',
      nameAr: 'صلاة الفجر',
      category: HabitCategory.spiritual,
      type: HabitType.prayer,
      icon: '🌅',
      colorValue: AppColors.spiritual.value,
      sortOrder: 0,
      scheduledTime: '06:00',
    ),
    HabitModel(
      nameEn: 'Dhuhr Prayer',
      nameAr: 'صلاة الظهر',
      category: HabitCategory.spiritual,
      type: HabitType.prayer,
      icon: '☀️',
      colorValue: AppColors.spiritual.value,
      sortOrder: 1,
      scheduledTime: '13:30',
    ),
    HabitModel(
      nameEn: 'Asr Prayer',
      nameAr: 'صلاة العصر',
      category: HabitCategory.spiritual,
      type: HabitType.prayer,
      icon: '🌤️',
      colorValue: AppColors.spiritual.value,
      sortOrder: 2,
      scheduledTime: '16:40',
    ),
    HabitModel(
      nameEn: 'Maghrib Prayer',
      nameAr: 'صلاة المغرب',
      category: HabitCategory.spiritual,
      type: HabitType.prayer,
      icon: '🌇',
      colorValue: AppColors.spiritual.value,
      sortOrder: 3,
      scheduledTime: '19:20',
    ),
    HabitModel(
      nameEn: 'Isha Prayer',
      nameAr: 'صلاة العشاء',
      category: HabitCategory.spiritual,
      type: HabitType.prayer,
      icon: '🌙',
      colorValue: AppColors.spiritual.value,
      sortOrder: 4,
      scheduledTime: '21:00',
    ),
    HabitModel(
      nameEn: 'Quran Reading',
      nameAr: 'قراءة القرآن',
      category: HabitCategory.spiritual,
      type: HabitType.quran,
      icon: '📖',
      colorValue: AppColors.spiritual.value,
      sortOrder: 5,
      targetValue: 4,
      targetUnit: 'pages',
    ),
    // ===== ENGLISH =====
    HabitModel(
      nameEn: 'English Study',
      nameAr: 'دراسة الإنجليزية',
      category: HabitCategory.english,
      type: HabitType.study,
      icon: '🇬🇧',
      colorValue: AppColors.english.value,
      sortOrder: 6,
      targetValue: 90,
      targetUnit: 'minutes',
      scheduledTime: '07:00',
    ),
    // ===== FITNESS =====
    HabitModel(
      nameEn: 'Gym Training',
      nameAr: 'التمرين الرياضي',
      category: HabitCategory.fitness,
      type: HabitType.exercise,
      icon: '💪',
      colorValue: AppColors.fitness.value,
      sortOrder: 7,
      targetValue: 60,
      targetUnit: 'minutes',
      scheduledTime: '08:30',
    ),
    // ===== BUSINESS =====
    HabitModel(
      nameEn: 'Focused Work',
      nameAr: 'العمل المركّز',
      category: HabitCategory.business,
      type: HabitType.work,
      icon: '💼',
      colorValue: AppColors.business.value,
      sortOrder: 8,
      targetValue: 270,
      targetUnit: 'minutes',
      scheduledTime: '10:30',
    ),
    // ===== FAMILY =====
    HabitModel(
      nameEn: 'Family Time',
      nameAr: 'وقت العائلة',
      category: HabitCategory.family,
      type: HabitType.family,
      icon: '👨‍👩‍👧‍👦',
      colorValue: AppColors.family.value,
      sortOrder: 9,
      scheduledTime: '16:00',
    ),
    HabitModel(
      nameEn: 'Important Calls',
      nameAr: 'المكالمات المهمة',
      category: HabitCategory.family,
      type: HabitType.family,
      icon: '📞',
      colorValue: AppColors.family.value,
      sortOrder: 10,
    ),
    // ===== KNOWLEDGE =====
    HabitModel(
      nameEn: 'Reading (10 pages)',
      nameAr: 'القراءة (١٠ صفحات)',
      category: HabitCategory.knowledge,
      type: HabitType.reading,
      icon: '📚',
      colorValue: AppColors.knowledge.value,
      sortOrder: 11,
      targetValue: 10,
      targetUnit: 'pages',
    ),
  ];
}

class HabitsRepository {
  static int calculateStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;
    final sorted = logs.where((l) => l.completed).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (sorted.isEmpty) return 0;

    int streak = 0;
    DateTime check = DateTime.now();

    for (final log in sorted) {
      final diff = check.difference(log.date).inDays;
      if (diff <= 1) {
        streak++;
        check = log.date.subtract(const Duration(days: 1));
      } else break;
    }
    return streak;
  }

  static double calculateConsistencyRate(List<HabitLog> logs, DateTime since) {
    final totalDays = DateTime.now().difference(since).inDays.clamp(1, 9999);
    final completedDays = logs.where((l) => l.completed).length;
    return (completedDays / totalDays).clamp(0.0, 1.0);
  }

  static int totalQuranPages(List<HabitLog> logs) {
    return logs.where((l) => l.completed && l.value != null)
        .fold(0, (sum, l) => sum + (l.value ?? 0));
  }

  static int prayersCompletedToday(Map<String, HabitLog?> todayLogs, List<HabitModel> habits) {
    final prayers = habits.where((h) => h.type == HabitType.prayer);
    return prayers.where((p) => todayLogs[p.id]?.completed == true).length;
  }
}
