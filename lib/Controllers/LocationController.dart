import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Models/TrackingAreaHome.dart';
import 'package:mwpaapp/Services/EventManagerService.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilNotificationPermission.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:mwpaapp/Util/UtilTourTracking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Models/TourTracking.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// GpsStatus - state of the position stream as shown on the main screen
enum GpsStatus {
  /// no position stream: location service off, permission missing or the
  /// stream failed (restarted by the watchdog)
  off,

  /// stream running, but no (recent) position fix
  searching,

  /// recent position fix
  ok,
}

/// LocationController
class LocationController extends ChangeNotifier {

  /// how often a stopped position stream is restarted / the status re-checked
  static const Duration watchdogInterval = Duration(seconds: 15);

  /// a fix older than this counts as "searching"; the stream delivers one
  /// every 10 s
  static const Duration fixStaleAfter = Duration(seconds: 60);

  final PrefController _prefController;
  final SightingController _sightingController;

  LocationController(this._prefController, this._sightingController) {
    _resumeHomeAreaTour();
  }

  /// continue a home area tour that was running before an app restart (crash,
  /// reboot, app killed by Android) instead of starting a new tour
  void _resumeHomeAreaTour() {
    final stored = _prefController.homeAreaTour;

    if (stored == null) {
      return;
    }

    if (UtilTourTracking.canResumeHomeAreaTour(
        stored: stored,
        currentTour: _prefController.prefToru,
        now: DateTime.now())) {
      homeAreaToru = stored;
    } else {
      // tour of an earlier day or home area mode switched off
      _prefController.saveHomeAreaTour(null);
    }
  }

  /// geoloactor android
  final GeolocatorPlatform geolocatorAndroid = GeolocatorPlatform.instance;

  /// stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  /// is location init
  bool isLocationInit = false;

  /// watchdog: restarts a stopped position stream, updates [gpsStatus]
  Timer? locationTimer;

  /// time of the last position fix
  DateTime? _lastFixAt;

  GpsStatus _gpsStatus = GpsStatus.off;

  /// gpsStatus - off / searching / ok, listeners are notified on change
  GpsStatus get gpsStatus => _gpsStatus;

  /// Current position
  Position? currentPosition;

  /// Current position count
  int positionCount = 0;

  /// Home Area Points (Polygon)
  List<UtilLocationDouble> homeArea = [];

  /// a tour by home area
  TourPref? homeAreaToru;

  /// recorded route of the running tour (oldest first), drawn on the map
  final List<UtilLocationDouble> route = [];

  /// tour the [route] belongs to
  String? _routeFid;

  /// event manager for updates
  final EventManagerService updateEvent = EventManagerService();

  /// start location tracking only when the prominent disclosure was accepted
  void initIfConfirmed() {
    if (!isLocationInit) {
      if (_prefController.prominentDisclosureConfirmed) {
        initLocation();
      }
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    locationTimer?.cancel();
    super.dispose();
  }

  /// running initLocation call, prevents two concurrent position streams
  Future<bool>? _initLocationFuture;

  /// initLocation - starts the position stream (and the watchdog that keeps
  /// it running); [requestPermission] false only checks the permission, the
  /// watchdog must not pop up the permission dialog every few seconds
  Future<bool> initLocation({bool requestPermission = true}) {
    locationTimer ??= Timer.periodic(watchdogInterval, (_) => _watchdog());

    return _initLocationFuture ??= _initLocation(requestPermission).whenComplete(() {
      _initLocationFuture = null;
      _updateGpsStatus();
    });
  }

  /// _watchdog - a position stream stops on an error (location switched off,
  /// provider failure); start it again as soon as possible
  void _watchdog() {
    if (_positionStreamSubscription == null) {
      initLocation(requestPermission: false);
    } else {
      _updateGpsStatus();
    }
  }

  /// computeGpsStatus - status for a stream that is [running] with the last
  /// fix at [lastFixAt]
  static GpsStatus computeGpsStatus({
    required bool running,
    required DateTime? lastFixAt,
    required DateTime now,
  }) {
    if (!running) {
      return GpsStatus.off;
    }

    if (lastFixAt == null || now.difference(lastFixAt) > fixStaleAfter) {
      return GpsStatus.searching;
    }

    return GpsStatus.ok;
  }

  void _updateGpsStatus() {
    final status = computeGpsStatus(
      running: _positionStreamSubscription != null,
      lastFixAt: _lastFixAt,
      now: DateTime.now(),
    );

    if (status != _gpsStatus) {
      AppLog.i('Location', 'GPS status ${_gpsStatus.name} -> ${status.name}');
      _gpsStatus = status;
      notifyListeners();
    }
  }

  /// _stopStream - after an error or the end of the position stream; the
  /// watchdog restarts it
  void _stopStream([Object? error]) {
    AppLog.w('Location', 'position stream stopped: ${error ?? 'done'}');

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _updateGpsStatus();
  }

  /// _initLocation
  Future<bool> _initLocation(bool requestPermission) async {
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
        if (!requestPermission) {
          return false;
        }

        permission = await geolocatorAndroid.requestPermission();

        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Android 13+: allow the tracking notification of the foreground
      // service; tracking also runs without it
      if (requestPermission) {
        await UtilNotificationPermission.request();
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
            notificationIcon: AndroidResource(name: 'ic_stat_tracking')
        ),
      );

      final positionStream = geolocatorAndroid.getPositionStream(
          locationSettings: androidSettings
      );

      _positionStreamSubscription = positionStream.listen((position) {
        positionCount++;
        _lastFixAt = DateTime.now();
        // set silently, _setAndSavePosition notifies the listeners
        if (_gpsStatus != GpsStatus.ok) {
          AppLog.i('Location', 'GPS status ${_gpsStatus.name} -> ok');
        }
        _gpsStatus = GpsStatus.ok;

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

        AppLog.d('Location', tPosition.toString());

        _setAndSavePosition(tPosition);
        updateEvent.triggerEvent();
      },
        onError: _stopStream,
        onDone: _stopStream,
        cancelOnError: true,
      );
    }

    return true;
  }

  /// resetTour - forget the running home area tour and the home area of the
  /// previous user (logout); tracking points are only saved again once a
  /// tour is set
  void resetTour() {
    homeAreaToru = null;
    homeArea = [];
    route.clear();
    _routeFid = null;
    notifyListeners();
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
      AppLog.e('Location', 'loadHomeArea failed', e);

      rethrow;
    }
  }

  /// _setAndSavePosition
  void _setAndSavePosition(Position position) {
    currentPosition = position;

    var savePoint = false;
    var tourFid = "";

    PrefController prefController = _prefController;

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

              UtilSighting.setCurrentEndTour(_sightingController, UtilTourFid.createTTourFId(homeAreaToru!));
              homeAreaToru = null;

              // back home: the tour is over, its route leaves the map
              route.clear();
              _routeFid = null;
              prefController.saveHomeAreaTour(null);
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
              // end of the previous home area tour no longer applies
              prefController.prefToru?.tour_end = "";

              // keep it across app restarts
              prefController.saveHomeAreaTour(homeAreaToru);

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

      final point = UtilLocationDouble.positionToLocationDouble(currentPosition!);

      DBHelper.insertTourTracking(
          TourTracking(
              uuid: uuidStr,
              tour_fid: tourFid,
              location: jsonEncode(currentPosition!.toJson()),
              date: timeStr
          )
      ).then((_) => _addRoutePoint(tourFid, point)).catchError((Object error) {
        AppLog.e('Location', 'save tracking point failed', error);
      });
    }

    notifyListeners();
  }

  /// _addRoutePoint - appends a saved point; for a new tour (or after an app
  /// restart) the route is read from the DB once, including this point
  Future<void> _addRoutePoint(String tourFid, UtilLocationDouble point) async {
    if (tourFid == _routeFid) {
      route.add(point);
      notifyListeners();
      return;
    }

    _routeFid = tourFid;
    final loaded = <UtilLocationDouble>[];

    try {
      for (final json in await DBHelper.queryTourTrackingLocations(tourFid)) {
        final map = jsonDecode(json);
        loaded.add(UtilLocationDouble(
          lat: (map['latitude'] as num).toDouble(),
          lon: (map['longitude'] as num).toDouble(),
        ));
      }
    } catch (error) {
      AppLog.w('Location', 'route not readable', error);
      loaded
        ..clear()
        ..add(point);
    }

    // another tour started while reading
    if (_routeFid != tourFid) {
      return;
    }

    route
      ..clear()
      ..addAll(loaded);
    AppLog.d('Location', 'route of $tourFid: ${route.length} points');
    notifyListeners();
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
      AppLog.w('Location', 'getLocationBy $tourFId', e);
    }

    return null;
  }
}