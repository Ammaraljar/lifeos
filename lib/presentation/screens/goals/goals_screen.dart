import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
    final logs = ref.watch(logsProvider);
    final logsN = ref.read(logsProvider.notifier);
    final isAr = locale == 'ar';

    // Build goal data from habits
    final logsN = ref.read(logsProvider.notifier);
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
    final prayerConsistency = logs.annualPrayerConsistency(habits);
    final quranPages = logs.annualQuranPages(habits);
    final englishHours = logs.annualEnglishHours(habits);

    final gymHabit = habits.where((h) => h.type == HabitType.exercise).firstOrNull;
    final gymDays = gymHabit != null
        ? logs.logsFor(gymHabit.id).where((l) => l.date.isAfter(DateTime(DateTime.now().year, 1, 1)) && l.completed).length
        : 0;

    final workHabit = habits.where((h) => h.type == HabitType.work).firstOrNull;
    final workDays = workHabit != null
        ? logs.logsFor(workHabit.id).where((l) => l.date.isAfter(DateTime(DateTime.now().year, 1, 1)) && l.completed).length
        : 0;

    final readingHabit = habits.where((h) => h.type == HabitType.reading).firstOrNull;
    final readingDays = readingHabit != null
        ? logs.logsFor(readingHabit.id).where((l) => l.date.isAfter(DateTime(DateTime.now().year, 1, 1)) && l.completed).length
        : 0;

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;

    return [
      _GoalData(
        icon: '🕌',
        titleAr: 'الارتقاء بالعبادة والروحانية',
        titleEn: 'Spiritual & Religious Growth',
        color: AppColors.spiritual,
        progress: prayerConsistency,
        stats: [
          _Stat(isAr ? 'انتظام الصلاة' : 'Prayer Consistency', '${(prayerConsistency * 100).round()}%', '90%'),
          _Stat(isAr ? 'صفحات القرآن' : 'Quran Pages', '$quranPages', '${AppConstants.quranPagesPerYear}'),
        ],
        milestones: isAr
            ? ['✅ المحافظة على الصلوات الخمس', '📖 قراءة ٤ صفحات يومياً', '🎯 ١٤٦٠ صفحة سنوياً', '⭐ انتظام ٩٠٪+']
            : ['✅ All 5 daily prayers', '📖 4 Quran pages daily', '🎯 1,460 pages annually', '⭐ 90%+ consistency'],
      ),
      _GoalData(
        icon: '🇬🇧',
        titleAr: 'تطوير اللغة الإنجليزية',
        titleEn: 'English Language Development',
        color: AppColors.english,
        progress: (englishHours / 500).clamp(0, 1),
        stats: [
          _Stat(isAr ? 'ساعات الدراسة' : 'Study Hours', '${englishHours.round()}', '500'),
          _Stat(isAr ? 'أيام متتالية' : 'Study Days', '$dayOfYear', '365'),
        ],
        milestones: isAr
            ? ['📚 ٥٠٠+ ساعة دراسة', '🗣️ تحسين المحادثة والاستماع', '✍️ تطوير الكتابة والقراءة', '🎯 الطلاقة في المحادثة']
            : ['📚 500+ study hours', '🗣️ Improve speaking & listening', '✍️ Writing & reading skills', '🎯 Conversational fluency'],
      ),
      _GoalData(
        icon: '💪',
        titleAr: 'اللياقة البدنية والصحة',
        titleEn: 'Physical Fitness & Health',
        color: AppColors.fitness,
        progress: (gymDays / 200).clamp(0, 1),
        stats: [
          _Stat(isAr ? 'أيام التمرين' : 'Gym Days', '$gymDays', '200'),
          _Stat(isAr ? 'معدل الاتساق' : 'Consistency', '${((gymDays / dayOfYear.clamp(1, 999)) * 100).round()}%', '80%'),
        ],
        milestones: isAr
            ? ['🏋️ تمرين يومي منتظم', '💪 تحسين اللياقة البدنية', '🥗 نمط حياة صحي', '⚡ ٢٠٠+ يوم تمرين']
            : ['🏋️ Consistent daily exercise', '💪 Improve physical fitness', '🥗 Healthy lifestyle', '⚡ 200+ gym days'],
      ),
      _GoalData(
        icon: '💼',
        titleAr: 'تطوير الأعمال والإنتاجية',
        titleEn: 'Business Growth & Productivity',
        color: AppColors.business,
        progress: (workDays / 250).clamp(0, 1),
        stats: [
          _Stat(isAr ? 'أيام العمل المركّز' : 'Focused Work Days', '$workDays', '250'),
          _Stat(isAr ? 'معدل الإنتاجية' : 'Productivity Rate', '${((workDays / dayOfYear.clamp(1, 999)) * 100).round()}%', '90%'),
        ],
        milestones: isAr
            ? ['🚀 تطوير جسور الجلوبال والسياحة', '📈 إتمام المشاريع التجارية', '🤝 تحسين المبيعات والشراكات', '⚡ زيادة الإنتاجية']
            : ['🚀 Grow Jusoor Global & tourism', '📈 Complete business projects', '🤝 Improve sales & partnerships', '⚡ Increase productivity'],
      ),
      _GoalData(
        icon: '👨‍👩‍👧‍👦',
        titleAr: 'العائلة والعلاقات الاجتماعية',
        titleEn: 'Family & Social Relationships',
        color: AppColors.family,
        progress: 0.6,
        stats: [
          _Stat(isAr ? 'وقت العائلة' : 'Family Time', isAr ? 'يومي' : 'Daily', '✅'),
          _Stat(isAr ? 'بناء العلاقات' : 'Relationship Building', isAr ? 'مستمر' : 'Ongoing', '✅'),
        ],
        milestones: isAr
            ? ['❤️ وقت نوعي مع العائلة', '📞 تعزيز العلاقات الشخصية', '🤝 المحافظة على التواصل', '👥 بناء شبكة علاقات قوية']
            : ['❤️ Quality time with family', '📞 Strengthen relationships', '🤝 Maintain communication', '👥 Build strong network'],
      ),
      _GoalData(
        icon: '📚',
        titleAr: 'التطوير الذاتي والمعرفي',
        titleEn: 'Knowledge & Personal Development',
        color: AppColors.knowledge,
        progress: (readingDays / 300).clamp(0, 1),
        stats: [
          _Stat(isAr ? 'أيام القراءة' : 'Reading Days', '$readingDays', '300'),
          _Stat(isAr ? 'صفحات القراءة' : 'Reading Pages', '${readingDays * 10}', '${300 * 10}'),
        ],
        milestones: isAr
            ? ['📖 ١٠ صفحات يومياً على الأقل', '📚 إتمام كتب متعددة', '🧠 التعلم المستمر مدى الحياة', '✨ تطوير الذات باستمرار']
            : ['📖 At least 10 pages daily', '📚 Finish multiple books', '🧠 Lifelong learning journey', '✨ Continuous self-development'],
      ),
    ];
  }
}

class _GoalData {
  final String icon, titleAr, titleEn;
  final Color color;
  final double progress;
  final List<_Stat> stats;
  final List<String> milestones;
  const _GoalData({required this.icon, required this.titleAr, required this.titleEn, required this.color, required this.progress, required this.stats, required this.milestones});
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
    final pct = (d.progress * 100).round();

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.getTitle(widget.locale),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                      color: widget.isDark ? AppColors.textPrimary : AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: d.progress.clamp(0, 1),
                        backgroundColor: c.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(c),
                        minHeight: 8,
                      ),
                    )),
                    const SizedBox(width: 10),
                    Text('$pct%', style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 14)),
                  ]),
                ])),
                const SizedBox(width: 8),
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
                  child: Text(m, style: TextStyle(fontSize: 13, color: widget.isDark ? AppColors.textSecondary : AppColors.primary.withOpacity(0.7))),
                )),
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
