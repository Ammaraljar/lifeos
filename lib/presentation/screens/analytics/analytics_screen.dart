import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../data/models/habit_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(darkModeProvider);
    final habits = ref.watch(habitsProvider);
    ref.watch(logsProvider);
    final logsN = ref.read(logsProvider.notifier);
    final isAr = locale == 'ar';

    final weekData = logsN.weekCompletions(habits);
    final total = habits.length.clamp(1, 999);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analytics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.thisWeek, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(isAr ? 'إنجاز العادات اليومية' : 'Daily habit completions',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(BarChartData(
                maxY: total.toDouble(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final days = isAr
                          ? ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت']
                          : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                      final idx = v.toInt().clamp(0, 6);
                      return Text(days[idx], style: const TextStyle(color: AppColors.textMuted, fontSize: 10));
                    },
                  )),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: weekData.entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value.toDouble(),
                    color: e.value == total ? AppColors.green : AppColors.highlight,
                    width: 28,
                    borderRadius: BorderRadius.circular(8),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true, toY: total.toDouble(),
                      color: AppColors.highlight.withOpacity(0.1),
                    ),
                  )],
                )).toList(),
              )),
            ),
          ])),
          const SizedBox(height: 14),

          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'التسلسلات الحالية 🔥' : 'Current Streaks 🔥',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...habits.map((h) {
              final streak = logsN.streakFor(h.id);
              final color = Color(h.colorValue);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Text(h.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(h.getName(locale),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (streak / 30).clamp(0, 1),
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ])),
                  const SizedBox(width: 10),
                  Text(streak > 0 ? '🔥 $streak' : '—',
                    style: TextStyle(
                      color: streak > 0 ? AppColors.warning : AppColors.textMuted,
                      fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
              );
            }),
          ])),
          const SizedBox(height: 14),

          _Card(isDark: isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'تحليل بالفئة' : 'Category Breakdown',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...[
              (HabitCategory.spiritual, isAr ? 'الروحانية' : 'Spiritual', AppColors.spiritual),
              (HabitCategory.english, isAr ? 'الإنجليزية' : 'English', AppColors.english),
              (HabitCategory.fitness, isAr ? 'اللياقة' : 'Fitness', AppColors.fitness),
              (HabitCategory.business, isAr ? 'الأعمال' : 'Business', AppColors.business),
              (HabitCategory.family, isAr ? 'العائلة' : 'Family', AppColors.family),
              (HabitCategory.knowledge, isAr ? 'المعرفة' : 'Knowledge', AppColors.knowledge),
            ].map((cat) {
              final catHabits = habits.where((h) => h.category == cat.$1).toList();
              if (catHabits.isEmpty) return const SizedBox.shrink();
              final completedToday = catHabits.where((h) => logsN.isCompletedToday(h.id)).length;
              final rate = completedToday / catHabits.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  SizedBox(width: 80, child: Text(cat.$2,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  const SizedBox(width: 8),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: cat.$3.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(cat.$3),
                      minHeight: 12,
                    ),
                  )),
                  const SizedBox(width: 10),
                  Text('$completedToday/${catHabits.length}',
                    style: TextStyle(color: cat.$3, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              );
            }),
          ])),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.card : Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
    ),
    child: child,
  );
}
