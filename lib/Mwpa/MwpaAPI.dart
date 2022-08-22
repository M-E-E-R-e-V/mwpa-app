import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mwpaapp/Mwpa/Models/IsLogin.dart';
import 'package:mwpaapp/Mwpa/Models/LoginResponse.dart';
import 'package:path/path.dart' as p;

class MwpaApi {

  static const URL_ISLOGIN = 'mobile/islogin';
  static const URL_LOGIN = 'mobile/login';

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

    return isLogin.status;
  }

  Future<bool> login(String email, String password) async {
    var url = getUrl(MwpaApi.URL_LOGIN);

    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        email: email,
        password: password
      }),
    );

    var lresponse = LoginResponse.fromJson(jsonDecode(response.body));

    if (lresponse.success) {
      if (response.headers.containsKey('set-cookie')) {
        _cookie = response.headers['set-cookie']!;
      }

      return true;
    }

    return false;
  }

}