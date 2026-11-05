import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/LanguageSelector.dart';
import 'package:mwpaapp/Controllers/LocaleController.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => Intl.defaultLocale = null);

  group('LocaleController', () {
    test('defaults to English', () async {
      SharedPreferences.setMockInitialValues({});
      final c = LocaleController();
      await c.load();

      expect(c.language, AppLanguage.en);
      expect(c.locale, const Locale('en'));
    });

    test('loads the stored language, unknown codes fall back to English', () async {
      SharedPreferences.setMockInitialValues({Preference.LANGUAGE: 'es'});
      final c = LocaleController();
      await c.load();
      expect(c.language, AppLanguage.es);

      SharedPreferences.setMockInitialValues({Preference.LANGUAGE: 'xx'});
      await c.load();
      expect(c.language, AppLanguage.en);
    });

    test('setLanguage persists, notifies and sets the Intl default', () async {
      SharedPreferences.setMockInitialValues({});
      final c = LocaleController();
      await c.load();
      var notified = 0;
      c.addListener(() => notified++);

      await c.setLanguage(AppLanguage.de);

      expect(notified, 1);
      expect(Intl.defaultLocale, 'de');
      expect((await SharedPreferences.getInstance()).getString(Preference.LANGUAGE), 'de');
      // numeric patterns stay locale independent (stored dates)
      expect(DateFormat('yyyy-MM-dd HH:mm').format(DateTime(2026, 11, 5, 9, 7)), '2026-11-05 09:07');
    });

    test('selection order: English, German, Spanish', () {
      expect(AppLanguage.values, [AppLanguage.en, AppLanguage.de, AppLanguage.es]);
      expect(AppLanguage.values.map((l) => l.locale), unorderedEquals(AppLocalizations.supportedLocales));
    });
  });

  test('all ARB files have the same keys', () {
    Set<String> keys(String lang) =>
        (jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>)
            .keys
            .where((k) => !k.startsWith('@'))
            .toSet();

    final en = keys('en');
    expect(keys('de'), en);
    expect(keys('es'), en);
  });

  testWidgets('LanguageSelector switches the UI language', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = LocaleController();
    await tester.runAsync(controller.load);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<LocaleController>(
        builder: (context, c, _) => MaterialApp(
          locale: c.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(actions: const [LanguageSelector()]),
            body: Builder(builder: (context) => Text(context.l10n.save)),
          ),
        ),
      ),
    ));

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('🇬🇧'), findsOneWidget);

    await tester.tap(find.text('🇬🇧'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(controller.language, AppLanguage.de);
    expect(find.text('Speichern'), findsOneWidget);
    expect(find.text('🇩🇪'), findsOneWidget);
  });
}
