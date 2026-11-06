import 'package:flutter/material.dart';
import 'package:mwpaapp/Controllers/LocaleController.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// LanguageSelector - flag of the current UI language; tapping opens the
/// selection (English, Deutsch, Español)
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final current = controller.language;

    return PopupMenuButton<AppLanguage>(
      tooltip: context.l10n.language,
      initialValue: current,
      onSelected: controller.setLanguage,
      icon: Text(current.flag, style: const TextStyle(fontSize: 24)),
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Row(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Text(language.nativeName)),
                if (language == current) const Icon(Icons.check, size: 20),
              ],
            ),
          ),
      ],
    );
  }
}
