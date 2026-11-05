import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilDevice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/TourPref.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// PrefController
class PrefController extends ChangeNotifier {

  bool isLogin = false;
  bool prominentDisclosureConfirmed = false;
  TourPref? prefToru;

  /// running tour of the home-area mode, see Preference.HOME_AREA_TOUR
  TourPref? homeAreaTour;

  /// display stays on while the app is in front, see Preference.KEEP_SCREEN_ON
  bool keepScreenOn = false;

  /// load
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // read user accept tracking settings ------------------------------------

      if (prefs.containsKey(Preference.PROMINENT_DISCLOSURE_CONFIRMED)) {
        final pdc = prefs.getBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED);

        if (pdc != null) {
          prominentDisclosureConfirmed = pdc ? true : false;
        }
      }

      // is login --------------------------------------------------------------
      isLogin = false;

      if (prefs.containsKey(Preference.USERID)) {
        isLogin = true;
      }

      // read default tour settings --------------------------------------------

      if (prefs.containsKey(Preference.TOUR)) {
        final pTourStr = prefs.getString(Preference.TOUR);

        if (pTourStr != null) {
          prefToru = TourPref.fromJson(jsonDecode(pTourStr));
        }
      }

      // read running home area tour -------------------------------------------

      final homeAreaTourStr = prefs.getString(Preference.HOME_AREA_TOUR);

      if (homeAreaTourStr != null) {
        homeAreaTour = TourPref.fromJson(jsonDecode(homeAreaTourStr));
      }

      keepScreenOn = prefs.getBool(Preference.KEEP_SCREEN_ON) ?? false;
      await UtilDevice.setKeepScreenOn(keepScreenOn);
    } catch(e) {
      AppLog.e('Pref', 'load failed', e);
    }

    notifyListeners();
  }

  /// saveTour
  Future<void> saveTour(TourPref tour) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Preference.TOUR, jsonEncode(tour.toJson()));
    } catch(e) {
      AppLog.e('Pref', 'saveTour failed', e);
    }

    prefToru = tour;
    notifyListeners();
  }

  /// setKeepScreenOn - stores the setting and applies it right away
  Future<void> setKeepScreenOn(bool on) async {
    keepScreenOn = on;
    await UtilDevice.setKeepScreenOn(on);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Preference.KEEP_SCREEN_ON, on);
    } catch(e) {
      AppLog.e('Pref', 'setKeepScreenOn failed', e);
    }

    notifyListeners();
  }

  /// saveHomeAreaTour - store the running home area tour, null removes it
  Future<void> saveHomeAreaTour(TourPref? tour) async {
    homeAreaTour = tour;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (tour == null) {
        await prefs.remove(Preference.HOME_AREA_TOUR);
      } else {
        await prefs.setString(Preference.HOME_AREA_TOUR, jsonEncode(tour.toJson()));
      }
    } catch(e) {
      AppLog.e('Pref', 'saveHomeAreaTour failed', e);
    }
  }

  /// logout - removes the session and everything that belongs to the user
  /// or its organization (default tour with boat/skipper ids, running home
  /// area tour); URL and username stay to prefill the login. The password
  /// is removed by CredentialStore.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final key in [
        Preference.USERID,
        Preference.ORGID,
        Preference.TOUR,
        Preference.HOME_AREA_TOUR,
      ]) {
        await prefs.remove(key);
      }
    } catch(e) {
      AppLog.e('Pref', 'logout failed', e);
    }

    isLogin = false;
    prefToru = null;
    homeAreaTour = null;
    notifyListeners();
  }

  /// saveProminentDisclosureConfirmed
  Future<void> saveProminentDisclosureConfirmed(bool confirmed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED, confirmed);

      prominentDisclosureConfirmed = confirmed;
    } catch(e) {
      AppLog.e('Pref', 'saveProminentDisclosureConfirmed failed', e);
    }
  }
}