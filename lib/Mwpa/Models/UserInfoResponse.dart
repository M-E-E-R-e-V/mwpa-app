import 'package:mwpaapp/Mwpa/Models/User/UserInfo.dart';
import 'DefaultReturn.dart';

class UserInfoResponse extends DefaultReturn {
  final UserInfo? data;

  UserInfoResponse({required super.statusCode, super.msg, this.data});

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    UserInfo? data;

    if (json.containsKey('data')) {
      data = UserInfo.fromJson(json['data']);
    }

    return UserInfoResponse(
      statusCode: json['statusCode'],
      msg: msg,
      data: data
    );
  }
}