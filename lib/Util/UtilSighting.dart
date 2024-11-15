
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';

/// Sighting Helper
class UtilSighting {

  /// set the End Tour date and save all sightings
  static Future<void> setCurrentEndTour(String tourFid) async {
    TimeOfDay timeValue = TimeOfDay.now();
    var hour = "${timeValue.hour}";
    var min = "${timeValue.minute}";

    if (timeValue.hour < 10) {
      hour = "0${timeValue.hour}";
    }

    if (timeValue.minute < 10) {
      min = "0${timeValue.minute}";
    }

    var tourEndTime = "$hour:$min";

    final SightingController sightingController = Get.put(SightingController());
    await sightingController.updateSightingEndtour(
        tourFid,
        tourEndTime
    );
  }

}