import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../data/models/habit_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(darkModeProvider);
    final habits = ref.watch(habitsProvider);
    ref.watch(logsProvider); // rebuild on log changes
    final logsN = ref.read(logsProvider.notifier);
    final completion = ref.watch(todayCompletionProvider);
    final isAr = locale == 'ar';

    final now = DateTime.now();
    final prayers = habits.where((h) => h.type == HabitType.prayer).toList();
    final prayersToday = logsN.prayersToday(habits);
    final quranPages = logsN.annualQuranPages(habits);
    final englishHours = logsN.annualEnglishHours(habits);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), AppColors.highlight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAr ? _arabicGreeting() : _englishGreeting(),
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr
                                  ? DateFormat('EEEE، d MMMM', 'ar').format(now)
                                  : DateFormat('EEEE, MMMM d').format(now),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        CircularPercentIndicator(
                          radius: 36,
                          lineWidth: 6,
                          percent: completion,
                          center: Text(
                            '${(completion * 100).round()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          progressColor: AppColors.green,
                          backgroundColor: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionTitle(isAr ? 'الصلوات — $prayersToday/5' : 'Prayers — $prayersToday/5'),
                const SizedBox(height: 10),
                _PrayersRow(prayers: prayers),
                const SizedBox(height: 20),

                _SectionTitle(isAr ? 'عادات اليوم' : "Today's Habits"),
                const SizedBox(height: 10),
                ...habits.where((h) => h.type != HabitType.prayer).map((h) =>
                    _HabitTile(habit: h, locale: locale, isDark: isDark)),
                const SizedBox(height: 20),

                _SectionTitle(isAr ? 'إحصائيات هذا العام' : "This Year's Stats"),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: '📖', label: isAr ? 'صفحات القرآن' : 'Quran Pages',
                    value: '$quranPages', target: '${AppConstants.quranPagesPerYear}',
                    color: AppColors.spiritual,
                    progress: quranPages / AppConstants.quranPagesPerYear, isDark: isDark,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: '🇬🇧', label: isAr ? 'ساعات الإنجليزية' : 'English Hours',
                    value: '${englishHours.round()}', target: '500',
                    color: AppColors.english,
                    progress: englishHours / 500, isDark: isDark,
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: '🙏', label: isAr ? 'انتظام الصلاة' : 'Prayer Consistency',
                    value: '${(logsN.annualPrayerConsistency(habits) * 100).round()}%', target: '90%',
                    color: AppColors.spiritual,
                    progress: logsN.annualPrayerConsistency(habits), isDark: isDark,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(
                    icon: '💪', label: isAr ? 'أيام التمرين' : 'Gym Days',
                    value: '${_gymDays(habits, logsN)}', target: '200',
                    color: AppColors.fitness,
                    progress: _gymDays(habits, logsN) / 200, isDark: isDark,
                  )),
                ]),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  int _gymDays(List<HabitModel> habits, LogsNotifier logs) {
    final gym = habits.where((h) => h.type == HabitType.exercise).firstOrNull;
    if (gym == null) return 0;
    final since = DateTime(DateTime.now().year, 1, 1);
    return logs.logsFor(gym.id).where((l) => l.date.isAfter(since) && l.completed).length;
  }

  String _arabicGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير 🌅';
    if (h < 17) return 'مساء الخير ☀️';
    return 'مساء النور 🌙';
  }

  String _englishGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning 🌅';
    if (h < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }
}

class _PrayersRow extends ConsumerWidget {
  final List<HabitModel> prayers;
  const _PrayersRow({required this.prayers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(logsProvider);
    final logsN = ref.read(logsProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: prayers.map((p) {
        final done = logsN.isCompletedToday(p.id);
        return GestureDetector(
          onTap: () => ref.read(logsProvider.notifier).toggleToday(p.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 58, height: 72,
            decoration: BoxDecoration(
              color: done ? AppColors.spiritual : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: done ? AppColors.spiritual : AppColors.textMuted.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(p.nameAr.replaceAll('صلاة ', ''),
                  style: TextStyle(fontSize: 9, color: done ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
                if (done) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  final HabitModel habit;
  final String locale;
  final bool isDark;
  const _HabitTile({required this.habit, required this.locale, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(logsProvider);
    final logsN = ref.read(logsProvider.notifier);
    final done = logsN.isCompletedToday(habit.id);
    final streak = logsN.streakFor(habit.id);
    final color = Color(habit.colorValue);

    return GestureDetector(
      onTap: () => ref.read(logsProvider.notifier).toggleToday(habit.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? color.withOpacity(0.12) : (isDark ? AppColors.card : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: done ? color.withOpacity(0.4) : color.withOpacity(0.15), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: done ? color : color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(habit.getName(locale),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                  color: done ? color : (isDark ? AppColors.textPrimary : AppColors.primary))),
              const SizedBox(height: 3),
              Row(children: [
                if (habit.scheduledTime != null) ...[
                  const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(habit.scheduledTime!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(width: 10),
                ],
                if (habit.targetValue != null) ...[
                  const Icon(Icons.track_changes_rounded, size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text('${habit.targetValue} ${habit.targetUnit ?? ""}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(width: 10),
                ],
                if (streak > 0) ...[
                  const Text('🔥', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 2),
                  Text('$streak', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ]),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 30, height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : Colors.transparent,
              border: Border.all(color: done ? color : AppColors.textMuted.withOpacity(0.4), width: 2),
            ),
            child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value, target;
  final Color color;
  final double progress;
  final bool isDark;
  const _StatCard({required this.icon, required this.label, required this.value, required this.target, required this.color, required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('$value / $target', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary));
}
