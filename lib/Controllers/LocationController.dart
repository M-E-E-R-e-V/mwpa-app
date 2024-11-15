import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Models/TrackingAreaHome.dart';
import 'package:mwpaapp/Services/EventManagerService.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Models/TourTracking.dart';

/// LocationController
class LocationController extends GetxController {

  /// geoloactor android
  final GeolocatorPlatform geolocatorAndroid = GeolocatorPlatform.instance;

  /// stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  /// is location init
  bool isLocationInit = false;

  /// Location timer
  Timer? locationTimer;

  /// Current position
  Position? currentPosition;

  /// Current position count
  int positionCount = 0;

  /// Home Area Points (Polygon)
  List<UtilLocationDouble> homeArea = [];

  /// a tour by home area
  TourPref? homeAreaToru;

  /// event manager for updates
  final EventManagerService updateEvent = EventManagerService();

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
          locationSettings: androidSettings
      );

      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) {
        positionCount++;
        Position tPosition = Position(
            longitude: position.longitude,
            latitude: position.latitude,
            timestamp: position.timestamp,
            accuracy: position.accuracy,
            altitude: position.altitude,
            speed: position.speed,
            speedAccuracy: position.speedAccuracy,
            heading: position.heading,
            altitudeAccuracy: position.altitudeAccuracy,
            headingAccuracy: position.headingAccuracy
        );

        if (kDebugMode) {
          print(tPosition.toString());
        }

        _setAndSavePosition(tPosition);
        updateEvent.triggerEvent();
      });
    }

    return true;
  }

  /// Reload the settings
  Future<void> reloadSettings({bool reset = false}) async {
    await _loadHomeArea();
  }

  /// load Home Area
  Future<void> _loadHomeArea() async {
    try {
      homeArea = [];

      final prefs = await SharedPreferences.getInstance();
      final orgId = prefs.getInt(Preference.ORGID) ?? 0;

      if (orgId > 0) {
        List<Map<String, dynamic>> list = await DBHelper.queryTrackingAreaHome(orgId);

        for (var cord in list) {
          var tah = TrackingAreaHome.fromJson(cord);

          if (tah.lat != null && tah.lon != null) {
            var dCord = UtilLocationString(lat: tah.lat!, lon: tah.lon!).toLocationDouble();

            homeArea.add(dCord);
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('LocationController::_loadHomeArea:');
        print(e);
      }

      rethrow;
    }
  }

  /// _setAndSavePosition
  _setAndSavePosition(Position position) {
    currentPosition = position;

    var savePoint = false;
    var tourFid = "";

    PrefController prefController = Get.find<PrefController>();

    if (prefController.prefToru != null) {
      if ((prefController.prefToru!.use_home_area != null) && (prefController.prefToru!.use_home_area! > 0)) {
        // track with home area ------------------------------------------------

        if (homeArea.isNotEmpty) {
          if (UtilLocationPolygon.isPointInPolygon(
              UtilLocationDouble.positionToLocationDouble(currentPosition!),
              homeArea)
          ) {
            // at home area ----------------------------------------------------

            if (homeAreaToru != null) {
              prefController.prefToru?.tour_end = DateFormat("HH:mm").format(DateTime.now());
              prefController.saveTour(prefController.prefToru!);

              UtilSighting.setCurrentEndTour(UtilTourFid.createTTourFId(homeAreaToru!));
              homeAreaToru = null;
            }

            positionCount = 0;
          } else {
            // out home area ---------------------------------------------------

            if (homeAreaToru == null) {
              homeAreaToru = TourPref(
                  vehicle_id: prefController.prefToru?.vehicle_id,
                  vehicle_driver_id: prefController.prefToru?.vehicle_driver_id,
                  date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                  tour_start: DateFormat("HH:mm").format(DateTime.now())
              );

              prefController.prefToru?.date = homeAreaToru?.date;
              prefController.prefToru?.tour_start = homeAreaToru?.tour_start;

              // save the new tour info for sighting
              prefController.saveTour(prefController.prefToru!);
            }

            savePoint = true;
            tourFid = UtilTourFid.createTTourFId(homeAreaToru!);
          }
        }

      } else {
        // track all -----------------------------------------------------------

        savePoint = true;
        tourFid = UtilTourFid.createTTourFId(prefController.prefToru!);
      }
    }

    // save the point ----------------------------------------------------------

    if (savePoint) {
      DateTime cTime = DateTime.now();
      var uuid = const Uuid();
      String uuidStr = uuid.v4();
      String timeStr = cTime.toUtc().toString();

      DBHelper.insertTourTracking(
          TourTracking(
              uuid: uuidStr,
              tour_fid: tourFid,
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
      //String timeStr = date.toUtc().toString();
      String timeStr = date.toString();

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