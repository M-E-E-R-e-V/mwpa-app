import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

/// Info
class Info extends DefaultReturn {
  final String? version_api_login;
  final String? version_api_sync;

  /// Info
  const Info({required super.statusCode, super.msg, this.version_api_login, this.version_api_sync});

  /// fromJson
  factory Info.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    String? versionApiLogin;

    if (json.containsKey('version_api_login')) {
      versionApiLogin = json['version_api_login'];
    }

    String? versionApiSync;

    if (json.containsKey('version_api_sync')) {
      versionApiSync = json['version_api_sync'];
    }

    return Info(
      statusCode: json['statusCode'],
      msg: msg,
      version_api_login: versionApiLogin,
      version_api_sync: versionApiSync
    );
  }
}