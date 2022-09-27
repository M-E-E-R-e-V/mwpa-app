import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Location/LocationProvider.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:uuid/uuid.dart';

import '../Models/TourTracking.dart';

class LocationController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    locationTimer = scheduleTimeout(10 * 1000);
  }

  Timer? locationTimer;
  Position? currentPosition;

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer.periodic(Duration(milliseconds: milliseconds), callLocation);

  Future<void> callLocation(Timer time) async {
    try {
      var position = await LocationProvider.getLocation();
      currentPosition = position;

      PrefController _prefController = Get.find<PrefController>();

      if (_prefController != null && _prefController.prefToru != null) {
        DateTime cTime = DateTime.now();
        var uuid = const Uuid();
        String uuidStr = uuid.v4();
        String timeStr = cTime.toUtc().toString();

        DBHelper.insertTourTracking(
          TourTracking(
            uuid: uuidStr,
            tour_fid: UtilTourFid.createTTourFId(_prefController.prefToru!),
            location: jsonEncode(currentPosition!.toJson()),
            date: timeStr
          )
        );
      }

      update();
    } catch(e) {
      if (kDebugMode) {
        print("LocationController:callLocation");
        print(e);
      }
    }
  }

  Future<Position?> getLocationBy(String tourFId, DateTime date) async {
    try {
      String timeStr = date.toUtc().toString();

      var timeParts = timeStr.split(":");
      var newTimeSearch = "${timeParts[0]}:${timeParts[1]}";

      var data = await DBHelper.readTourTracking(tourFId, newTimeSearch);

      if (data.isNotEmpty) {
        TourTracking tour = TourTracking.fromJson(data);

        Position tLocation = Position.fromMap(jsonDecode(tour.location!));

        return tLocation;
      }
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return null;
  }
}