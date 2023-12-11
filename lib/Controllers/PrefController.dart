import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/TourPref.dart';

/// PrefController
class PrefController extends GetxController {

  bool isLogin = false;
  bool prominentDisclosureConfirmed = false;
  TourPref? prefToru;

  /// onReady
  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// load
  load() async {
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
    } catch(e) {
      if (kDebugMode) {
        print("PrefController:load");
        print(e);
      }
    }

    update();
  }

  /// saveTour
  saveTour(TourPref tour) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Preference.TOUR, jsonEncode(tour.toJson()));
    } catch(e) {
      if (kDebugMode) {
        print("PrefController:saveTour");
        print(e);
      }
    }

    prefToru = tour;
    update();
  }

  /// saveProminentDisclosureConfirmed
  saveProminentDisclosureConfirmed(bool confirmed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Preference.PROMINENT_DISCLOSURE_CONFIRMED, confirmed);

      prominentDisclosureConfirmed = confirmed;
    } catch(e) {
      if (kDebugMode) {
        print("PrefController:saveProminentDisclosureConfirmed");
        print(e);
      }
    }
  }
}