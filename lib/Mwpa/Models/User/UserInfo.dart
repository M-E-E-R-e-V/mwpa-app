import 'package:mwpaapp/Mwpa/Models/User/UserInfoData.dart';

class UserInfo {
  final bool islogin;
  final UserInfoData? user;

  const UserInfo({required this.islogin, this.user});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    UserInfoData? user;

    if (json.containsKey('user')) {
      user = UserInfoData.fromJson(json['user']);
    }

    return UserInfo(
      islogin: json['islogin'],
      user: user
    );
  }
}