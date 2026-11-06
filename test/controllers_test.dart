import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/ThemeController.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrefController', () {
    test('load reads login, disclosure flag and tour', () async {
      SharedPreferences.setMockInitialValues({
        Preference.USERID: 42,
        Preference.PROMINENT_DISCLOSURE_CONFIRMED: true,
        Preference.TOUR: jsonEncode(TourPref(vehicle_id: 1, date: '2026-06-08').toJson()),
      });

      final pref = PrefController();
      await pref.load();

      expect(pref.isLogin, isTrue);
      expect(pref.prominentDisclosureConfirmed, isTrue);
      expect(pref.prefToru?.vehicle_id, 1);
      expect(pref.prefToru?.date, '2026-06-08');
    });

    test('load without stored values', () async {
      SharedPreferences.setMockInitialValues({});

      final pref = PrefController();
      await pref.load();

      expect(pref.isLogin, isFalse);
      expect(pref.prominentDisclosureConfirmed, isFalse);
      expect(pref.prefToru, isNull);
    });

    test('saveTour persists and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});

      final pref = PrefController();
      var notified = 0;
      pref.addListener(() => notified++);

      await pref.saveTour(TourPref(vehicle_id: 5, date: '2026-06-08'));

      final prefs = await SharedPreferences.getInstance();
      final stored = TourPref.fromJson(jsonDecode(prefs.getString(Preference.TOUR)!));

      expect(stored.vehicle_id, 5);
      expect(pref.prefToru?.vehicle_id, 5);
      expect(notified, 1);
    });
  });

  group('ThemeController', () {
    test('defaults to light mode', () async {
      SharedPreferences.setMockInitialValues({});

      final theme = ThemeController();
      await theme.load();

      expect(theme.themeMode, ThemeMode.light);
    });

    test('switchTheme toggles, persists and notifies', () async {
      SharedPreferences.setMockInitialValues({});

      final theme = ThemeController();
      await theme.load();

      var notified = 0;
      theme.addListener(() => notified++);

      await theme.switchTheme();

      final prefs = await SharedPreferences.getInstance();
      expect(theme.themeMode, ThemeMode.dark);
      expect(prefs.getBool(Preference.DARK_MODE), isTrue);
      expect(notified, 1);

      // a fresh controller restores the stored choice
      final restored = ThemeController();
      await restored.load();
      expect(restored.themeMode, ThemeMode.dark);
    });
  });
}
