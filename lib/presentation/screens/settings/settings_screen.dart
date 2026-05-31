import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyCtrl = TextEditingController();
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyCtrl.text = ref.read(apiKeyProvider);
    });
  }

  @override
  void dispose() { _keyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isDark = ref.watch(darkModeProvider);
    final isAr = locale == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Language
          _Section(isAr ? 'اللغة' : 'Language'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _LangCard(
              flag: '🇸🇦', label: 'العربية', selected: locale == 'ar',
              onTap: () => ref.read(localeProvider.notifier).set('ar'),
              isDark: isDark,
            )),
            const SizedBox(width: 12),
            Expanded(child: _LangCard(
              flag: '🇺🇸', label: 'English', selected: locale == 'en',
              onTap: () => ref.read(localeProvider.notifier).set('en'),
              isDark: isDark,
            )),
          ]),
          const SizedBox(height: 24),

          // Theme
          _Section(isAr ? 'المظهر' : 'Theme'),
          const SizedBox(height: 12),
          _ToggleRow(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            label: isDark ? l10n.darkMode : l10n.lightMode,
            value: isDark,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            color: AppColors.highlight,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // AI Key
          _Section(isAr ? 'مفتاح الذكاء الاصطناعي' : 'AI API Key'),
          const SizedBox(height: 8),
          Text(
            isAr ? 'اختياري — لتفعيل التحليل الذكي والاقتراحات' : 'Optional — for smart analysis and suggestions',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            obscureText: !_showKey,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'sk-ant-...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.surface : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: Icon(_showKey ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textMuted, size: 20),
                onPressed: () => setState(() => _showKey = !_showKey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await ref.read(apiKeyProvider.notifier).save(_keyCtrl.text.trim());
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'تم الحفظ ✓' : 'Saved ✓'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.highlight, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text(l10n.saveKey, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),

          // About
          _Section(isAr ? 'عن التطبيق' : 'About'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(children: [
                const Text('🎯', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('LifeOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary)),
                  Text(isAr ? 'نظام الحياة الشخصي' : 'Personal Life Operating System',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const Text('v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5));
}

class _LangCard extends StatelessWidget {
  final String flag, label;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _LangCard({required this.flag, required this.label, required this.selected, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: selected ? AppColors.highlight.withOpacity(0.15) : (isDark ? AppColors.card : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.highlight : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(children: [
        Text(flag, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.highlight : AppColors.textSecondary,
        )),
        if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.highlight, size: 16),
      ]),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;
  final Color color;
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.card : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const Spacer(),
      Switch(value: value, onChanged: onChanged, activeColor: color),
    ]),
  );
}
