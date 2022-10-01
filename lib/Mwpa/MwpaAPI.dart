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
import 'package:mwpaapp/Mwpa/Models/IsLogin.dart';
import 'package:mwpaapp/Mwpa/Models/LoginResponse.dart';
import 'package:mwpaapp/Mwpa/Models/SightingSaveResponse.dart';
import 'package:mwpaapp/Mwpa/Models/SpeciesListResponse.dart';
import 'package:mwpaapp/Mwpa/Models/StatusCodes.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfoData.dart';
import 'package:mwpaapp/Mwpa/Models/UserInfoResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleDriverResponse.dart';
import 'package:mwpaapp/Mwpa/Models/VehicleResponse.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:path/path.dart' as p;

class MwpaApi {

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

  String _url = "";
  String _cookie = "";
  bool _isLogin = false;

  MwpaApi(String url) {
    _url = url;
  }

  String getUrl(String path) {
    return p.join(_url, path);
  }

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
      throw Exception('Connection error');
    }
  }

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
      throw Exception('Connection error');
    }
  }

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
      print(error);
      throw Exception('Connection error');
    }
  }

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
      print(error);
      throw Exception('Connection error');
    }
  }

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
      print(error);
      throw Exception('Connection error');
    }
  }

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
      print(error);
      throw Exception('Connection error');
    }
  }

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
      print(error);
      throw Exception('Connection error');
    }
  }

  Future<String?> saveSighting(Sighting sigh) async {
    try {
      var url = getUrl(MwpaApi.URL_SIGHTING_SAVE);

      var postBody = jsonEncode(sigh.toJson(false));

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
      print(error);
      throw Exception('Connection error');
    }

    return null;
  }

  Future<bool> saveSightingImage(String unid, String imgFile) async {
    try {
      if ( File(imgFile).existsSync()) {
        String filename = p.basename(imgFile);

        try {

          final file = await File(imgFile).open(mode: FileMode.read);
          var byte;

          var filesize = file.lengthSync();
          var offset = 0;

          while (byte != -1) {
            List<int> buffer = [];

            for(var i=0; i<50000; i++) {
              byte = await file.readByte();

              if (byte != -1) {
                buffer.add(byte);
              }

              offset++;
            }

            var url = getUrl(MwpaApi.URL_SIGHTING_IMAGE_SAVE);
            var postBody = jsonEncode(<String, dynamic>{
              'unid': unid,
              'filename': filename,
              'size': filesize,
              'offset': offset,
              'data': base64Encode(buffer)
            });

            var response = await http.post(
              Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'cookie': _cookie
              },
              body: postBody,
            );

            var objResponse = DefaultReturn.fromJson(jsonDecode(response.body));

            if (objResponse.statusCode != StatusCodes.OK) {
              throw Exception('Image can not update!');
            }
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
      print(error);
      throw Exception('Connection error');
    }

    return false;
  }
}