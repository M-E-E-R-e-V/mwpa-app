import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mwpaapp/Mwpa/Models/IsLogin.dart';
import 'package:mwpaapp/Mwpa/Models/LoginResponse.dart';
import 'package:mwpaapp/Mwpa/Models/StatusCodes.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfoData.dart';
import 'package:mwpaapp/Mwpa/Models/UserInfoResponse.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:path/path.dart' as p;

class MwpaApi {

  static const URL_ISLOGIN = 'mobile/islogin';
  static const URL_LOGIN = 'mobile/login';
  static const URL_USERINFO = 'mobile/user/info';

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

      var lresponse = LoginResponse.fromJson(jsonDecode(response.body));

      if (lresponse.success) {
        if (response.headers.containsKey('set-cookie')) {
          _cookie = response.headers['set-cookie']!;
        }

        return true;
      } else {
        if (lresponse.error != null) {
          throw MwpaException(lresponse.error!);
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

      var lresponse = UserInfoResponse.fromJson(jsonDecode(response.body));

      if (lresponse.statusCode == StatusCodes.OK) {
        return lresponse.data!.user!;
      } else {
        if (lresponse.msg != null) {
          throw MwpaException(lresponse.msg!);
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
}