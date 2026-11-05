import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilTourTracking.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 11, 5, 14, 30);
  final homeMode = TourPref(vehicle_id: 1, use_home_area: 1);

  TourPref started(String date, [String start = '09:15']) =>
      TourPref(vehicle_id: 1, vehicle_driver_id: 43, date: date, tour_start: start);

  group('UtilTourTracking.canResumeHomeAreaTour', () {
    test('resumes a tour of today in home area mode', () {
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: started('2026-11-05'), currentTour: homeMode, now: now), isTrue);
    });

    test('does not resume a tour of an earlier day', () {
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: started('2026-11-04'), currentTour: homeMode, now: now), isFalse);
    });

    test('does not resume when home area mode is off or no tour is set', () {
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: started('2026-11-05'), currentTour: TourPref(use_home_area: 0), now: now), isFalse);
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: started('2026-11-05'), currentTour: null, now: now), isFalse);
    });

    test('does not resume without stored tour or start time', () {
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: null, currentTour: homeMode, now: now), isFalse);
      expect(UtilTourTracking.canResumeHomeAreaTour(
          stored: started('2026-11-05', ''), currentTour: homeMode, now: now), isFalse);
    });
  });

  group('PrefController home area tour', () {
    test('saveHomeAreaTour persists, load reads it, null removes it', () async {
      SharedPreferences.setMockInitialValues({});

      final pref = PrefController();
      await pref.saveHomeAreaTour(started('2026-11-05'));

      final reloaded = PrefController();
      await reloaded.load();
      expect(reloaded.homeAreaTour?.tour_start, '09:15');
      expect(reloaded.homeAreaTour?.vehicle_driver_id, 43);

      await reloaded.saveHomeAreaTour(null);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(Preference.HOME_AREA_TOUR), isFalse);
      expect(reloaded.homeAreaTour, isNull);
    });
  });

  group('LocationController after app restart', () {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Future<PrefController> prefsWith(TourPref homeAreaTour, TourPref tour) async {
      SharedPreferences.setMockInitialValues({
        Preference.TOUR: jsonEncode(tour.toJson()),
        Preference.HOME_AREA_TOUR: jsonEncode(homeAreaTour.toJson()),
      });

      final pref = PrefController();
      await pref.load();
      return pref;
    }

    test('continues the running home area tour of today', () async {
      final pref = await prefsWith(started(today), homeMode);

      final location = LocationController(pref, SightingController());

      expect(location.homeAreaToru?.date, today);
      expect(location.homeAreaToru?.tour_start, '09:15');
    });

    test('drops a stale home area tour of an earlier day', () async {
      final pref = await prefsWith(started('2020-01-01'), homeMode);

      final location = LocationController(pref, SightingController());
      await Future<void>.delayed(Duration.zero);

      expect(location.homeAreaToru, isNull);
      expect(pref.homeAreaTour, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(Preference.HOME_AREA_TOUR), isFalse);
    });
  });
}
