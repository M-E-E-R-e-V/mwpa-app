import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Location/LocationProvider.dart';
import 'package:mwpaapp/Services/LocationBackgroundService.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:uuid/uuid.dart';
import 'package:background_locator_2/background_locator.dart';

import '../Models/TourTracking.dart';

/// LocationController
class LocationController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    locationTimer = scheduleTimeout(10 * 1000);
  }

  bool isLocationInit = false;
  Timer? locationTimer;
  Position? currentPosition;

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer.periodic(Duration(milliseconds: milliseconds), callLocation);

  /// _checkLocationPermission
  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();

    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );

        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }

      case PermissionStatus.granted:
        return true;

      default:
        return false;
    }
  }

  /// initLocation
  initLocation() async {
    await BackgroundLocator.initialize();

    if (await _checkLocationPermission()) {
      LocationBackgroundService.register((location) {
        Position tpos = Position(
            longitude: location.longitude,
            latitude: location.latitude,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                location.time.toInt()
            ),
            accuracy: location.accuracy,
            altitude: location.altitude,
            speed: location.speed,
            speedAccuracy: 0.0,
            heading: 0.0
        );

        _setAndSavePosition(tpos);
      }
      );

      isLocationInit = true;
    }

    final _isRunning = await BackgroundLocator.isServiceRunning();
    print(_isRunning);
  }

  /// _registerBackground
  _registerBackground() async {}

  /// _setAndSavePosition
  _setAndSavePosition(Position position) {
    currentPosition = position;

    PrefController prefController = Get.find<PrefController>();

    if (prefController.prefToru != null) {
      DateTime cTime = DateTime.now();
      var uuid = const Uuid();
      String uuidStr = uuid.v4();
      String timeStr = cTime.toUtc().toString();

      DBHelper.insertTourTracking(
          TourTracking(
              uuid: uuidStr,
              tour_fid: UtilTourFid.createTTourFId(prefController.prefToru!),
              location: jsonEncode(currentPosition!.toJson()),
              date: timeStr
          )
      );
    }

    update();
  }

  /// callLocation
  Future<void> callLocation(Timer time) async {
    if (!isLocationInit) {
      // init self when is accept
      PrefController prefController = Get.find<PrefController>();

      if (prefController.prominentDisclosureConfirmed) {
        initLocation();
      }

      return;
    }

    try {
      var tPos = await LocationProvider.getLocation();

      _setAndSavePosition(tPos);
    } catch(e) {
      if (kDebugMode) {
        print("LocationController:callLocation");
        print(e);
      }
    }
  }

  /// getLocationBy
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