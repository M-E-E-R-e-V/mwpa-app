import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/TourPref.dart';


class PrefController extends GetxController {

  TourPref? prefToru;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey(Preference.TOUR)) {
         prefToru = TourPref.fromJson(
            jsonDecode(prefs.getString(Preference.TOUR)!));
      }
    } catch(e) {
      if (kDebugMode) {
        print("PrefController:load");
        print(e);
      }
    }

    update();
  }

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
}