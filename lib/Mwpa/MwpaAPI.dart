import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
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
import 'package:mwpaapp/Mwpa/Models/SightingTourTrackingSave.dart';
import 'package:mwpaapp/Mwpa/Models/SpeciesListResponse.dart';
import 'package:mwpaapp/Mwpa/Models/StatusCodes.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfoData.dart';
import 'package:mwpaapp/Mwpa/Models/UserInfoResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleDriverResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleResponse.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:path/path.dart' as p;

import '../Models/TourTracking.dart';

/// MwpaApi
class MwpaApi {

  static const URL_INFO = 'mobile/info';
  static const URL_ISLOGIN = 'mobile/islogin';
  static const URL_LOGIN = 'mobile/login';
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

  String _url = "";
  String _cookie = "";
  bool _isLogin = false;

  /// MwpaApi
  MwpaApi(String url) {
    _url = url;
  }

  /// getUrl
  String getUrl(String path) {
    return p.join(_url, path);
  }

  /// isLogin
  Future<bool> isLogin() async {
    var url = getUrl(MwpaApi.URL_ISLOGIN);
    var response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': _cookie
      },
    );

    var isLogin = IsLogin.fromJson(jsonDecode(response.body));

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
        identifier = build.androidId;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to get platform version');
      }
    }

    return [deviceName, deviceVersion, identifier];
  }

  /// getInfo
  Future<Info> getInfo() async {
    try {
      var url = getUrl(MwpaApi.URL_INFO);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var objResponse = Info.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// login
  Future<bool> login(String email, String password) async {
    try {
      var deviceDetails = await _getDeviceDetails();

      var url = getUrl(MwpaApi.URL_LOGIN);
      var postBody = jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'deviceIdentity': deviceDetails[2],
        'deviceDescription': "${deviceDetails[0]} - ${deviceDetails[1]}"
      });

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: postBody,
      );

      var objResponse = LoginResponse.fromJson(jsonDecode(response.body));

      if (objResponse.success) {
        if (response.headers.containsKey('set-cookie')) {
          _cookie = response.headers['set-cookie']!;
        }

        return true;
      } else {
        if (objResponse.error != null) {
          throw MwpaException(objResponse.error!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getUserInfo
  Future<UserInfoData> getUserInfo() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_USERINFO);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = UserInfoResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.data!.user!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getVehicleList
  Future<List<Vehicle>> getVehicleList() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_VEHICLE);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = VehicleResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.list!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getVehicleDriverList
  Future<List<VehicleDriver>> getVehicleDriverList() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_VEHICLE_DRIVER);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = VehicleDriverResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.list!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getSpeciesList
  Future<List<Species>> getSpeciesList() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_SPECIES);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = SpeciesListResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.list!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getEncounterCategorieList
  Future<List<EncounterCategorie>> getEncounterCategorieList() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_ENC_CATE);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = EncounterCategoriesResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.list!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// getBehaviouralStateList
  Future<List<BehaviouralState>> getBehaviouralStateList() async {
    if (!_isLogin) {
      throw MwpaException('Please login first!');
    }

    try {
      var url = getUrl(MwpaApi.URL_BEH_STATE);

      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
      );

      var objResponse = BehaviouralStatesResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.list!;
      } else {
        if (objResponse.msg != null) {
          throw MwpaException(objResponse.msg!);
        }

        throw MwpaException('Response success false');
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }
  }

  /// saveSighting
  Future<String?> saveSighting(Sighting sigh) async {
    try {
      var url = getUrl(MwpaApi.URL_SIGHTING_SAVE);

      var postBody = jsonEncode(sigh.toJson(false, false));

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
        body: postBody,
      );

      var objResponse = SightingSaveResponse.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return objResponse.unid;
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }

    return null;
  }

  /// saveSightingImage
  Future<bool> saveSightingImage(String unid, String imgFile) async {
    try {
      if ( File(imgFile).existsSync()) {
        String filename = p.basename(imgFile);

        try {
          final file = await File(imgFile).open(mode: FileMode.read);
          var fileSize = file.lengthSync();
          var url = getUrl(MwpaApi.URL_SIGHTING_IMAGE_SAVE);

          var request = http.MultipartRequest('POST', Uri.parse(url));

          request.headers.addAll(<String, String>{
            'cookie': _cookie
          });

          request.fields['unid'] = unid;
          request.fields['filename'] = filename;
          request.fields['size'] = fileSize.toString();

          http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file', imgFile);

          request.files.add(multipartFile);

          http.StreamedResponse response = await request.send();

          final res = await http.Response.fromStream(response);
          var objResponse = DefaultReturn.fromJson(jsonDecode(res.body));

          if (objResponse.statusCode != StatusCodes.OK) {
            throw Exception('Image can not update!');
          }

          return true;
        } catch(te) {
          if (kDebugMode) {
            print(te);
          }
        }
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }

    return false;
  }

  /// existSightingImage
  Future<bool> existSightingImage(String unid, String imgFile) async {
    try {
      if ( File(imgFile).existsSync()) {
        String filename = p.basename(imgFile);

        try {
          final file = await File(imgFile).open(mode: FileMode.read);
          var fileSize = file.lengthSync();

          var url = getUrl(MwpaApi.URL_SIGHTING_IMAGE_EXIST);
          var ie = ImageExist(unid: unid, filename: filename, size: fileSize.toString());
          var postBody = jsonEncode(ie.toJson());

          var response = await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'cookie': _cookie
            },
            body: postBody,
          );

          var objResponse = ImageExistResponse.fromJson(jsonDecode(response.body));

          if (objResponse.statusCode == StatusCodes.OK) {
            if (objResponse.isExist != null) {
              return objResponse.isExist!;
            }
          }
        } catch(te) {
          if (kDebugMode) {
            print(te);
          }
        }
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }

    return false;
  }

  /// checkSightingTourTracking
  Future<bool> checkSightingTourTracking(SightingTourTrackingCheck trackCheck) async {
    try {
      var url = getUrl(MwpaApi.URL_SIGHTING_TOUR_TRACKING_CHECK);

      var postBody = jsonEncode(trackCheck.toJson());

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
        body: postBody,
      );

      var objResponse = DefaultReturn.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return true;
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }

    return false;
  }

  /// saveSightingTourTracking
  Future<bool> saveSightingTourTracking(List<TourTracking> trackList) async {
    try {
      var save = SightingTourTrackingSave.fromTrackingList(trackList);

      var url = getUrl(MwpaApi.URL_SIGHTING_TOUR_TRACKING_SAVE);

      var postBody = jsonEncode(save.toJson());

      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': _cookie
        },
        body: postBody,
      );

      var objResponse = DefaultReturn.fromJson(jsonDecode(response.body));

      if (objResponse.statusCode == StatusCodes.OK) {
        return true;
      }
    }
    on MwpaException {
      rethrow;
    } catch(error) {
      if (kDebugMode) {
        print(error);
      }

      throw Exception('Connection error');
    }

    return false;
  }
}