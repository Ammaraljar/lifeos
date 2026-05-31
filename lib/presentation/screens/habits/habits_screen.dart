import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../data/models/habit_model.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(darkModeProvider);
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(logsProvider);
    final isAr = locale == 'ar';

    final categories = [
      (HabitCategory.spiritual, l10n.spiritual, AppColors.spiritual, '🕌'),
      (HabitCategory.english, l10n.english, AppColors.english, '🇬🇧'),
      (HabitCategory.fitness, l10n.fitness, AppColors.fitness, '💪'),
      (HabitCategory.business, l10n.business, AppColors.business, '💼'),
      (HabitCategory.family, l10n.family, AppColors.family, '👨‍👩‍👧‍👦'),
      (HabitCategory.knowledge, l10n.knowledge, AppColors.knowledge, '📚'),
    ];

    final done = logs.completedTodayCount(habits);
    final total = habits.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.habits),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('$done/$total',
              style: TextStyle(color: AppColors.highlight, fontWeight: FontWeight.w700, fontSize: 16))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A237E), AppColors.highlight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isAr ? DateFormat('EEEE', 'ar').format(DateTime.now()) : DateFormat('EEEE').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  isAr ? DateFormat('d MMMM yyyy', 'ar').format(DateTime.now()) : DateFormat('MMMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ])),
              CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 28,
                child: Text('${(done / total.clamp(1, 999) * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ]),
          ),

          // Groups
          ...categories.map((cat) {
            final catHabits = habits.where((h) => h.category == cat.$1).toList();
            if (catHabits.isEmpty) return const SizedBox.shrink();
            final catDone = catHabits.where((h) => logs.isCompletedToday(h.id)).length;

            return _CategoryGroup(
              label: cat.$2,
              emoji: cat.$4,
              color: cat.$3,
              habits: catHabits,
              done: catDone,
              total: catHabits.length,
              logs: logs,
              locale: locale,
              isDark: isDark,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CategoryGroup extends ConsumerWidget {
  final String label, emoji, locale;
  final Color color;
  final List<HabitModel> habits;
  final int done, total;
  final LogsNotifier logs;
  final bool isDark;

  const _CategoryGroup({
    required this.label, required this.emoji, required this.color,
    required this.habits, required this.done, required this.total,
    required this.logs, required this.locale, required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDone = done == total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: allDone ? color.withOpacity(0.5) : color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: allDone ? color.withOpacity(0.15) : color.withOpacity(0.07),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? AppColors.textPrimary : AppColors.primary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: allDone ? color : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$done/$total',
                style: TextStyle(
                  color: allDone ? Colors.white : color,
                  fontWeight: FontWeight.w700, fontSize: 12,
                )),
            ),
          ]),
        ),
        // Habits
        ...habits.map((h) => _HabitRow(habit: h, logs: logs, locale: locale, color: color, isDark: isDark)),
      ]),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  final HabitModel habit;
  final LogsNotifier logs;
  final String locale;
  final Color color;
  final bool isDark;
  const _HabitRow({required this.habit, required this.logs, required this.locale, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = logs.isCompletedToday(habit.id);
    final streak = logs.streakFor(habit.id);

    return GestureDetector(
      onTap: () => ref.read(logsProvider.notifier).toggleToday(habit.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color.withOpacity(0.1))),
          color: done ? color.withOpacity(0.07) : Colors.transparent,
        ),
        child: Row(children: [
          Text(habit.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(habit.getName(locale),
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: done ? color : (isDark ? AppColors.textPrimary : AppColors.primary),
                )),
              if (habit.scheduledTime != null || habit.targetValue != null)
                const SizedBox(height: 2),
              Row(children: [
                if (habit.scheduledTime != null)
                  Text('⏰ ${habit.scheduledTime}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                if (habit.scheduledTime != null && habit.targetValue != null)
                  const Text('  ', style: TextStyle(fontSize: 11)),
                if (habit.targetValue != null)
                  Text('🎯 ${habit.targetValue} ${habit.targetUnit ?? ""}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                if (streak > 1) ...[
                  const Text('  🔥 ', style: TextStyle(fontSize: 11)),
                  Text('$streak', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ]),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : Colors.transparent,
              border: Border.all(color: done ? color : AppColors.textMuted.withOpacity(0.3), width: 2),
            ),
            child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
          ),
        ]),
      ),
    );
  }
}
