import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:uuid/uuid.dart';

import '../Models/TourTracking.dart';

/// LocationController
class LocationController extends GetxController {

  final GeolocatorPlatform geolocatorAndroid = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool isLocationInit = false;
  Timer? locationTimer;
  Position? currentPosition;

  @override
  void onReady() {
    super.onReady();

    if (!isLocationInit) {
      // init self when is accept
      PrefController prefController = Get.find<PrefController>();

      if (prefController.prominentDisclosureConfirmed) {
        initLocation();
      }

      return;
    }
  }

  /// initLocation
  Future<bool> initLocation() async {
    if (_positionStreamSubscription == null) {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await geolocatorAndroid.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return false;
      }

      permission = await geolocatorAndroid.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await geolocatorAndroid.requestPermission();

        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      final androidSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        intervalDuration: const Duration(seconds: 10),
        forceLocationManager: false,
        useMSLAltitude: true,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "MWPA app is tracking your route in background ...",
            notificationTitle: "MWPA app Tracking",
            enableWakeLock: false,
            notificationIcon: AndroidResource(name: 'ic_stat_onesignal_default')
        ),
      );

      final positionStream = geolocatorAndroid.getPositionStream(
          locationSettings: androidSettings);

      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) {
        Position tPosition = Position(
            longitude: position.longitude,
            latitude: position.latitude,
            timestamp: position.timestamp,
            accuracy: position.accuracy,
            altitude: position.altitude,
            speed: position.speed,
            speedAccuracy: position.speedAccuracy,
            heading: position.heading
        );

        if (kDebugMode) {
          print(tPosition.toString());
        }

        _setAndSavePosition(tPosition);
      });
    }

    return true;
  }

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