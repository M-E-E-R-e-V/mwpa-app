import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// IntroPage - three short pages on the first start (record sightings, tour
/// and route, offline). Can be skipped; shown again from the help page.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  /// show - opens the introduction as a full screen page and marks it seen
  static Future<void> show(BuildContext context) async {
    final prefs = context.read<PrefController>();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const IntroPage()),
    );

    if (!prefs.introSeen) {
      await prefs.setIntroSeen();
    }
  }

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final pages = [
      (Icons.add_location_alt_outlined, l10n.intro1Title, l10n.intro1Text),
      (Icons.route_outlined, l10n.intro2Title, l10n.intro2Text),
      (Icons.cloud_sync_outlined, l10n.intro3Title, l10n.intro3Text),
    ];
    final last = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: last ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                child: TextButton(
                  onPressed: last ? null : _close,
                  child: Text(l10n.introSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  for (final (icon, title, text) in pages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: kPrimaryHeaderColor,
                            child: Icon(icon, size: 56, color: kButtonBackgroundColor),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i == _index ? kButtonBackgroundColor : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kButtonBackgroundColor,
                      foregroundColor: kButtonFontColor,
                    ),
                    onPressed: last
                        ? _close
                        : () => _pages.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                    child: Text(last ? l10n.introDone : l10n.introNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
