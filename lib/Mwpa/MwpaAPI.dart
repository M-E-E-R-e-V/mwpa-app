import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Mwpa/Models/CoastlineResponse.dart';
import 'package:mwpaapp/Mwpa/Models/BehaviouralStatesResponse.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Mwpa/Models/EncounterCategoriesResponse.dart';
import 'package:mwpaapp/Mwpa/Models/ImageExist.dart';
import 'package:mwpaapp/Mwpa/Models/ImageExistResponse.dart';
import 'package:mwpaapp/Mwpa/Models/Info.dart';
import 'package:mwpaapp/Mwpa/Models/IsLogin.dart';
import 'package:mwpaapp/Mwpa/Models/LoginResponse.dart';
import 'package:mwpaapp/Mwpa/Models/SightingSaveResponse.dart';
import 'package:mwpaapp/Mwpa/Models/SightingTourTrackingCheck.dart';
import 'package:mwpaapp/Mwpa/Models/SightingTourTrackingCheckResponse.dart';
import 'package:mwpaapp/Mwpa/Models/SightingTourTrackingSave.dart';
import 'package:mwpaapp/Mwpa/Models/SpeciesListResponse.dart';
import 'package:mwpaapp/Mwpa/Models/StatusCodes.dart';
import 'package:mwpaapp/Mwpa/Models/TrackingAreaHomeData.dart';
import 'package:mwpaapp/Mwpa/Models/TrackingAreaHomeResponse.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfo.dart';
import 'package:mwpaapp/Mwpa/Models/UserInfoResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleDriverResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleResponse.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:path/path.dart' as p;

import '../Models/TourTracking.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// MwpaApi
class MwpaApi {

  static const URL_INFO = 'mobile/info';
  static const URL_ISLOGIN = 'mobile/islogin';
  static const URL_LOGIN = 'mobile/login';
  static const URL_QUICKCONNECT = 'mobile/quickconnect';
  static const URL_LOGIN_TOKEN = 'mobile/login/token';
  static const URL_LOGOUT_TOKEN = 'mobile/logout/token';
  static const URL_USERINFO = 'mobile/user/info';
  static const URL_VEHICLE = 'mobile/vehicle/list';
  static const URL_VEHICLE_DRIVER = 'mobile/vehicledriver/list';
  static const URL_SPECIES = 'mobile/species/list';
  static const URL_ENC_CATE = 'mobile/encountercategories/list';
  static const URL_BEH_STATE = 'mobile/behaviouralstates/list';
  static const URL_SIGHTING_SAVE = 'mobile/sighting/save';
  static const URL_SIGHTING_IMAGE_SAVE = 'mobile/sighting/image/save';
  static const URL_SIGHTING_IMAGE_EXIST = 'mobile/sighting/image/exist';
  static const URL_SIGHTING_TOUR_TRACKING_CHECK = 'mobile/sighting/tourtracking/check';
  static const URL_SIGHTING_TOUR_TRACKING_SAVE = 'mobile/sighting/tourtracking/save';
  static const URL_TRACKINGAREA_HOME = 'mobile/trackingarea/homearea';
  static const URL_COASTLINE = 'mobile/coastline';

  /// timeout of a single request; a sync in a dead spot must fail instead of
  /// hanging forever
  static const Duration requestTimeout = Duration(seconds: 30);

  /// timeout of an image upload (larger body over a slow mobile connection)
  static const Duration uploadTimeout = Duration(minutes: 2);

  String _url = "";
  String _cookie = "";
  bool _isLogin = false;

  /// one client per API instance: keeps the connection (and TLS session) to
  /// the server open across the many requests of a sync instead of a new
  /// handshake per request
  final http.Client _client;

  /// timeout of the JSON requests ([requestTimeout] unless set by a test)
  final Duration _timeout;

  /// MwpaApi - [client] and [timeout] for tests, default a new [http.Client]
  /// and [requestTimeout]
  MwpaApi(String url, {http.Client? client, Duration timeout = requestTimeout})
      : _client = client ?? http.Client(),
        _timeout = timeout {
    _url = url;
  }

  /// close - releases the connection; the instance can't be used afterwards
  void close() {
    _client.close();
  }

  /// getUrl
  String getUrl(String path) {
    return p.join(_url, path);
  }

  /// isLogin
  Future<bool> isLogin() async {
    final isLogin = await _guard(() async {
      final response = await _get(MwpaApi.URL_ISLOGIN);
      return IsLogin.fromJson(jsonDecode(response.body));
    });

    _isLogin = isLogin.status;
    return isLogin.status;
  }

  /// _getDeviceDetails
  Future<List<String>> _getDeviceDetails() async {
    String deviceName = "";
    String deviceVersion = "";
    String identifier = "";

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.id;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;

        if (data.identifierForVendor != null) {
          identifier = data.identifierForVendor!; //UUID for iOS
        }
      }
    } on PlatformException {
      AppLog.w('Api', 'device details not available');
    }

    return [deviceName, deviceVersion, identifier];
  }

  /// getInfo - public endpoint, sent without the session cookie
  Future<Info> getInfo() {
    return _guard(() async {
      final response = await _get(MwpaApi.URL_INFO, withCookie: false);
      return _checked(Info.fromJson(jsonDecode(response.body)));
    });
  }

  /// login
  Future<bool> login(String email, String password) async {
    final deviceDetails = await _getDeviceDetails();

    await _sessionLogin(MwpaApi.URL_LOGIN, <String, String>{
      'email': email,
      'password': password,
      'deviceIdentity': deviceDetails[2],
      'deviceDescription': "${deviceDetails[0]} - ${deviceDetails[1]}"
    });

    return true;
  }

  /// quickConnect
  /// Exchange a single-use Quick Connect OTP (scanned from the web QR) for a
  /// mobile session. The backend resolves the user from the OTP itself, so we
  /// only send {otp, deviceIdentity, deviceDescription} — no email/password.
  /// Returns the device token for later logins of this device ([tokenLogin],
  /// the password replacement), or null when the server doesn't issue one.
  Future<String?> quickConnect(String otp) async {
    final deviceDetails = await _getDeviceDetails();

    final response = await _sessionLogin(MwpaApi.URL_QUICKCONNECT, <String, String>{
      'otp': otp,
      'deviceIdentity': deviceDetails[2],
      'deviceDescription': "${deviceDetails[0]} - ${deviceDetails[1]}"
    });

    return response.deviceToken;
  }

  /// tokenLogin - login of a Quick Connect device with its device token
  /// (instead of a password)
  Future<bool> tokenLogin(String token) async {
    final deviceDetails = await _getDeviceDetails();

    await _sessionLogin(MwpaApi.URL_LOGIN_TOKEN, <String, String>{
      'token': token,
      'deviceIdentity': deviceDetails[2],
      'deviceDescription': "${deviceDetails[0]} - ${deviceDetails[1]}"
    });

    return true;
  }

  /// tokenLogout - revokes the device token on the server (app logout)
  Future<void> tokenLogout(String token) async {
    final deviceDetails = await _getDeviceDetails();

    await _guard(() async {
      final response = await _post(MwpaApi.URL_LOGOUT_TOKEN, <String, String>{
        'token': token,
        'deviceIdentity': deviceDetails[2],
      }, withCookie: false);

      final objResponse = LoginResponse.fromJson(jsonDecode(response.body));

      if (!objResponse.success) {
        throw MwpaException(objResponse.error ?? 'Response success false');
      }
    });
  }

  /// _sessionLogin - posts the login [body] and keeps the session cookie
  Future<LoginResponse> _sessionLogin(String path, Map<String, String> body) {
    return _guard(() async {
      final response = await _post(path, body, withCookie: false);
      final objResponse = LoginResponse.fromJson(jsonDecode(response.body));

      if (!objResponse.success) {
        throw MwpaException(objResponse.error ?? 'Response success false');
      }

      final cookie = response.headers['set-cookie'];

      if (cookie != null) {
        _cookie = cookie;
      }

      return objResponse;
    });
  }

  /// getUserInfo
  Future<UserInfo> getUserInfo() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_USERINFO, UserInfoResponse.fromJson);
    return response.data!;
  }

  /// getVehicleList
  Future<List<Vehicle>> getVehicleList() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_VEHICLE, VehicleResponse.fromJson);
    return response.list!;
  }

  /// getVehicleDriverList
  Future<List<VehicleDriver>> getVehicleDriverList() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_VEHICLE_DRIVER, VehicleDriverResponse.fromJson);
    return response.list!;
  }

  /// getSpeciesList
  Future<List<Species>> getSpeciesList() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_SPECIES, SpeciesListResponse.fromJson);
    return response.list!;
  }

  /// getEncounterCategorieList
  Future<List<EncounterCategorie>> getEncounterCategorieList() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_ENC_CATE, EncounterCategoriesResponse.fromJson);
    return response.list!;
  }

  /// getBehaviouralStateList
  Future<List<BehaviouralState>> getBehaviouralStateList() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_BEH_STATE, BehaviouralStatesResponse.fromJson);
    return response.list!;
  }

  /// getHomeAreaTrackingArea
  Future<TrackingAreaHomeData?> getHomeAreaTrackingArea() async {
    _requireLogin();

    final response = await _getChecked(MwpaApi.URL_TRACKINGAREA_HOME, TrackingAreaHomeResponse.fromJson);
    return response.data;
  }

  /// getCoastline - coast lines around the home area of the organization
  /// (without home area around [latitude]/[longitude]); null when the server
  /// does not know the endpoint yet (older backend)
  Future<CoastlineData?> getCoastline({double? latitude, double? longitude}) {
    _requireLogin();

    return _guard(() async {
      final response = await _post(MwpaApi.URL_COASTLINE, {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      if (response.statusCode == 404) {
        return null;
      }

      return _checked(CoastlineResponse.fromJson(jsonDecode(response.body))).data;
    });
  }

  /// saveSighting - null when the server refuses the sighting
  Future<SightingSaveResponse?> saveSighting(Sighting sigh) {
    return _guard(() async {
      final response = await _post(
        MwpaApi.URL_SIGHTING_SAVE,
        sigh.toJson(false, false),
      );

      final objResponse = SightingSaveResponse.fromJson(jsonDecode(response.body));
      return objResponse.statusCode == StatusCodes.OK ? objResponse : null;
    });
  }

  /// saveSightingImage - uploads the image file; false when the file is
  /// missing or the upload fails (an image never aborts the sync)
  Future<bool> saveSightingImage(String unid, String imgFile) async {
    final file = File(imgFile);

    if (!file.existsSync()) {
      return false;
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(getUrl(MwpaApi.URL_SIGHTING_IMAGE_SAVE)));

      request.headers['cookie'] = _cookie;
      request.fields['unid'] = unid;
      request.fields['filename'] = p.basename(imgFile);
      request.fields['size'] = file.lengthSync().toString();
      request.files.add(await http.MultipartFile.fromPath('file', imgFile));

      final response = await http.Response.fromStream(
        await _client.send(request).timeout(uploadTimeout),
      ).timeout(uploadTimeout);

      final objResponse = DefaultReturn.fromJson(jsonDecode(response.body));
      return objResponse.statusCode == StatusCodes.OK;
    } catch (error) {
      AppLog.w('Api', 'image upload failed: ${p.basename(imgFile)}', error);
    }

    return false;
  }

  /// existSightingImage - true when the server already has this image;
  /// false when the file is missing or the check fails
  Future<bool> existSightingImage(String unid, String imgFile) async {
    final file = File(imgFile);

    if (!file.existsSync()) {
      return false;
    }

    try {
      final ie = ImageExist(
        unid: unid,
        filename: p.basename(imgFile),
        size: file.lengthSync().toString(),
      );

      final response = await _post(MwpaApi.URL_SIGHTING_IMAGE_EXIST, ie.toJson());
      final objResponse = ImageExistResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.isExist ?? false;
      }
    } catch (error) {
      AppLog.w('Api', 'image exist check failed: ${p.basename(imgFile)}', error);
    }

    return false;
  }

  /// checkSightingTourTracking - null when the server refuses the check
  Future<SightingTourTrackingCheckResponse?> checkSightingTourTracking(SightingTourTrackingCheck trackCheck) {
    return _guard(() async {
      final response = await _post(MwpaApi.URL_SIGHTING_TOUR_TRACKING_CHECK, trackCheck.toJson());
      final objResponse = SightingTourTrackingCheckResponse.fromJson(jsonDecode(response.body));

      return objResponse.statusCode == StatusCodes.OK ? objResponse : null;
    });
  }

  /// saveSightingTourTracking
  Future<bool> saveSightingTourTracking(List<TourTracking> trackList) {
    return _guard(() async {
      final save = SightingTourTrackingSave.fromTrackingList(trackList);
      final response = await _post(MwpaApi.URL_SIGHTING_TOUR_TRACKING_SAVE, save.toJson());

      return DefaultReturn.fromJson(jsonDecode(response.body)).statusCode == StatusCodes.OK;
    });
  }

  // request helpers -----------------------------------------------------------

  void _requireLogin() {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }
  }

  Map<String, String> _headers(bool withCookie) {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (withCookie) 'cookie': _cookie,
    };
  }

  Future<http.Response> _get(String path, {bool withCookie = true}) {
    return _client
        .get(Uri.parse(getUrl(path)), headers: _headers(withCookie))
        .timeout(_timeout);
  }

  Future<http.Response> _post(String path, Object body, {bool withCookie = true}) {
    return _client
        .post(Uri.parse(getUrl(path)), headers: _headers(withCookie), body: jsonEncode(body))
        .timeout(_timeout);
  }

  /// _getChecked - GET [path] and parse it with [fromJson]; throws the
  /// server message when the status code is not OK
  Future<T> _getChecked<T extends DefaultReturn>(
      String path, T Function(Map<String, dynamic> json) fromJson) {
    return _guard(() async {
      final response = await _get(path);
      return _checked(fromJson(jsonDecode(response.body)));
    });
  }

  /// _checked - [response] when OK, otherwise a [MwpaException] with the
  /// server message
  static T _checked<T extends DefaultReturn>(T response) {
    if (response.statusCode != StatusCodes.OK) {
      throw MwpaException(response.msg ?? 'Response success false');
    }

    return response;
  }

  /// _guard - runs [request]; server-side errors ([MwpaException]) pass
  /// through, a timeout and every other failure (no network, refused, broken
  /// JSON, ...) become a connection exception
  static Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on MwpaException {
      rethrow;
    } on TimeoutException catch (error) {
      AppLog.w('Api', 'request timeout', error);

      throw const MwpaConnectionException(timeout: true);
    } catch (error) {
      AppLog.w('Api', 'connection error', error);

      throw const MwpaConnectionException();
    }
  }

}
