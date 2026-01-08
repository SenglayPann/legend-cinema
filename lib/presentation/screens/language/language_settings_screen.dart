import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/glass_container.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "language_settings_title".tr(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLanguageOption(
              context,
              locale: const Locale('en'),
              languageName: "English",
              flagEmoji: "🇺🇸",
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              locale: const Locale('km'),
              languageName: "ភាសាខ្មែរ",
              flagEmoji: "🇰🇭",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String languageName,
    required String flagEmoji,
  }) {
    final isSelected = context.locale == locale;

    return GestureDetector(
      onTap: () async {
        await context.setLocale(locale);
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(flagEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Text(
                  languageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }
}
