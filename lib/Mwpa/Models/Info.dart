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

    String? version_api_login;

    if (json.containsKey('version_api_login')) {
      version_api_login = json['version_api_login'];
    }

    String? version_api_sync;

    if (json.containsKey('version_api_sync')) {
      version_api_sync = json['version_api_sync'];
    }

    return Info(
      statusCode: json['statusCode'],
      msg: msg,
      version_api_login: version_api_login,
      version_api_sync: version_api_sync
    );
  }
}