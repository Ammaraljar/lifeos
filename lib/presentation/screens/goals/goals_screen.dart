import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../data/models/habit_model.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(darkModeProvider);
    final habits = ref.watch(habitsProvider);
    ref.watch(logsProvider);
    final logsN = ref.read(logsProvider.notifier);
    final isAr = locale == 'ar';

    final goalData = _buildGoalData(habits, logsN, isAr, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.annualGoals)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isAr ? '${DateTime.now().year} — أهدافي السنوية' : 'My ${DateTime.now().year} Annual Goals',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...goalData.map((g) => _GoalCard(data: g, isDark: isDark, locale: locale)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  List<_GoalData> _buildGoalData(List<HabitModel> habits, LogsNotifier logsN, bool isAr, AppLocalizations l10n) {
    final prayerConsistency = logsN.annualPrayerConsistency(habits);
    final quranPages = logsN.annualQuranPages(habits);
    final englishHours = logsN.annualEnglishHours(habits);
    final since = DateTime(DateTime.now().year, 1, 1);
    final dayOfYear = DateTime.now().difference(since).inDays + 1;

    final gymHabit = habits.where((h) => h.type == HabitType.exercise).firstOrNull;
    final gymDays = gymHabit != null ? logsN.logsFor(gymHabit.id).where((l) => l.date.isAfter(since) && l.completed).length : 0;

    final workHabit = habits.where((h) => h.type == HabitType.work).firstOrNull;
    final workDays = workHabit != null ? logsN.logsFor(workHabit.id).where((l) => l.date.isAfter(since) && l.completed).length : 0;

    final readingHabit = habits.where((h) => h.type == HabitType.reading).firstOrNull;
    final readingDays = readingHabit != null ? logsN.logsFor(readingHabit.id).where((l) => l.date.isAfter(since) && l.completed).length : 0;

    return [
      _GoalData(icon: '🕌', titleAr: 'الارتقاء بالعبادة والروحانية', titleEn: 'Spiritual & Religious Growth',
        color: AppColors.spiritual, progress: prayerConsistency,
        stats: [_Stat(isAr ? 'انتظام الصلاة' : 'Prayer Consistency', '${(prayerConsistency * 100).round()}%', '90%'),
                _Stat(isAr ? 'صفحات القرآن' : 'Quran Pages', '$quranPages', '${AppConstants.quranPagesPerYear}')],
        milestones: isAr ? ['✅ الصلوات الخمس', '📖 ٤ صفحات يومياً', '🎯 ١٤٦٠ صفحة', '⭐ ٩٠٪+']
            : ['✅ All 5 prayers', '📖 4 pages daily', '🎯 1,460 pages', '⭐ 90%+ consistency']),
      _GoalData(icon: '🇬🇧', titleAr: 'تطوير اللغة الإنجليزية', titleEn: 'English Language Development',
        color: AppColors.english, progress: (englishHours / 500).clamp(0, 1),
        stats: [_Stat(isAr ? 'ساعات الدراسة' : 'Study Hours', '${englishHours.round()}', '500'),
                _Stat(isAr ? 'أيام الدراسة' : 'Study Days', '$dayOfYear', '365')],
        milestones: isAr ? ['📚 ٥٠٠+ ساعة', '🗣️ تحسين المحادثة', '✍️ الكتابة', '🎯 الطلاقة']
            : ['📚 500+ hours', '🗣️ Speaking', '✍️ Writing', '🎯 Fluency']),
      _GoalData(icon: '💪', titleAr: 'اللياقة البدنية والصحة', titleEn: 'Physical Fitness & Health',
        color: AppColors.fitness, progress: (gymDays / 200).clamp(0, 1),
        stats: [_Stat(isAr ? 'أيام التمرين' : 'Gym Days', '$gymDays', '200'),
                _Stat(isAr ? 'الاتساق' : 'Consistency', '${((gymDays / dayOfYear.clamp(1, 999)) * 100).round()}%', '80%')],
        milestones: isAr ? ['🏋️ تمرين منتظم', '💪 تحسين اللياقة', '🥗 حياة صحية', '⚡ ٢٠٠+ يوم']
            : ['🏋️ Consistent exercise', '💪 Improve fitness', '🥗 Healthy lifestyle', '⚡ 200+ days']),
      _GoalData(icon: '💼', titleAr: 'تطوير الأعمال والإنتاجية', titleEn: 'Business Growth & Productivity',
        color: AppColors.business, progress: (workDays / 250).clamp(0, 1),
        stats: [_Stat(isAr ? 'أيام العمل' : 'Work Days', '$workDays', '250'),
                _Stat(isAr ? 'الإنتاجية' : 'Productivity', '${((workDays / dayOfYear.clamp(1, 999)) * 100).round()}%', '90%')],
        milestones: isAr ? ['🚀 جسور الجلوبال', '📈 المشاريع', '🤝 المبيعات', '⚡ الإنتاجية']
            : ['🚀 Jusoor Global', '📈 Projects', '🤝 Sales', '⚡ Productivity']),
      _GoalData(icon: '👨‍👩‍👧‍👦', titleAr: 'العائلة والعلاقات الاجتماعية', titleEn: 'Family & Relationships',
        color: AppColors.family, progress: 0.6,
        stats: [_Stat(isAr ? 'وقت العائلة' : 'Family Time', isAr ? 'يومي' : 'Daily', '✅'),
                _Stat(isAr ? 'العلاقات' : 'Networking', isAr ? 'مستمر' : 'Ongoing', '✅')],
        milestones: isAr ? ['❤️ وقت نوعي', '📞 تعزيز العلاقات', '🤝 التواصل', '👥 شبكة قوية']
            : ['❤️ Quality time', '📞 Strengthen bonds', '🤝 Communication', '👥 Strong network']),
      _GoalData(icon: '📚', titleAr: 'التطوير الذاتي والمعرفي', titleEn: 'Knowledge & Self-Development',
        color: AppColors.knowledge, progress: (readingDays / 300).clamp(0, 1),
        stats: [_Stat(isAr ? 'أيام القراءة' : 'Reading Days', '$readingDays', '300'),
                _Stat(isAr ? 'الصفحات' : 'Pages', '${readingDays * 10}', '3000')],
        milestones: isAr ? ['📖 ١٠ صفحات يومياً', '📚 كتب متعددة', '🧠 التعلم', '✨ تطوير الذات']
            : ['📖 10 pages daily', '📚 Multiple books', '🧠 Learning', '✨ Self-growth']),
    ];
  }
}

class _GoalData {
  final String icon, titleAr, titleEn;
  final Color color;
  final double progress;
  final List<_Stat> stats;
  final List<String> milestones;
  const _GoalData({required this.icon, required this.titleAr, required this.titleEn,
    required this.color, required this.progress, required this.stats, required this.milestones});
  String getTitle(String locale) => locale == 'ar' ? titleAr : titleEn;
}

class _Stat {
  final String label, value, target;
  const _Stat(this.label, this.value, this.target);
}

class _GoalCard extends StatefulWidget {
  final _GoalData data;
  final bool isDark;
  final String locale;
  const _GoalCard({required this.data, required this.isDark, required this.locale});
  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final c = d.color;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Row(children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 24)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.getTitle(widget.locale),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                      color: widget.isDark ? AppColors.textPrimary : AppColors.primary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: d.progress.clamp(0, 1),
                        backgroundColor: c.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(c), minHeight: 8))),
                    const SizedBox(width: 10),
                    Text('${(d.progress * 100).round()}%',
                      style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 14)),
                  ]),
                ])),
                Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted),
              ]),
              const SizedBox(height: 14),
              Row(children: d.stats.map((s) => Expanded(child: _StatChip(stat: s, color: c))).toList()),
            ]),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(color: c.withOpacity(0.2)),
                const SizedBox(height: 8),
                ...d.milestones.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(m, style: TextStyle(fontSize: 13,
                    color: widget.isDark ? AppColors.textSecondary : AppColors.primary.withOpacity(0.7))))),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final _Stat stat;
  final Color color;
  const _StatChip({required this.stat, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(stat.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      const SizedBox(height: 2),
      Text(stat.value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      Text('/ ${stat.target}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  );
}
