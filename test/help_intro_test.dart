import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Pages/HelpPage.dart';
import 'package:mwpaapp/Pages/IntroPage.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(PrefController prefs, Widget home, {Locale locale = const Locale('en')}) {
  return ChangeNotifierProvider.value(
    value: prefs,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

/// opens the introduction from a button, like ListPage/HelpPage do
class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(onPressed: () => IntroPage.show(context), child: const Text('open')),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('introSeen is loaded and stored', () async {
    final prefs = PrefController();
    await prefs.load();
    expect(prefs.introSeen, isFalse);

    await prefs.setIntroSeen();
    expect(prefs.introSeen, isTrue);
    expect((await SharedPreferences.getInstance()).getBool(Preference.INTRO_SEEN), isTrue);

    final reloaded = PrefController();
    await reloaded.load();
    expect(reloaded.introSeen, isTrue);
  });

  testWidgets('skipping the introduction marks it seen', (tester) async {
    final prefs = PrefController();
    await tester.pumpWidget(_app(prefs, const _Opener()));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Record sightings'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(IntroPage), findsNothing);
    expect(prefs.introSeen, isTrue);
  });

  testWidgets('introduction pages through to the end', (tester) async {
    final prefs = PrefController();
    await tester.pumpWidget(_app(prefs, const _Opener(), locale: const Locale('de')));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Tour und Route'), findsOneWidget);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Funktioniert offline'), findsOneWidget);

    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    expect(find.byType(IntroPage), findsNothing);
    expect(prefs.introSeen, isTrue);
  });

  testWidgets('help page opens sections and the introduction', (tester) async {
    final prefs = PrefController();
    await tester.pumpWidget(_app(prefs, const HelpPage()));

    // first section is open
    expect(find.textContaining('Red: a required field'), findsOneWidget);
    expect(find.textContaining('Everything is stored on the phone'), findsNothing);

    await tester.scrollUntilVisible(find.text('Sync and working offline'), 200);
    await tester.tap(find.text('Sync and working offline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Everything is stored on the phone'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Show introduction again'), 200);
    await tester.tap(find.text('Show introduction again'));
    await tester.pumpAndSettle();
    expect(find.text('Record sightings'), findsOneWidget);
  });
}
