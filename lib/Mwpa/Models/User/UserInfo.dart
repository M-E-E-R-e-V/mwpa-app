import 'package:mwpaapp/Mwpa/Models/User/UserInfoData.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfoGroup.dart';
import 'package:mwpaapp/Mwpa/Models/User/UserInfoOrg.dart';

class UserInfo {
  final bool islogin;
  final UserInfoData? user;
  final UserInfoGroup? group;
  final UserInfoOrg? organization;

  const UserInfo({required this.islogin, this.user, this.group, this.organization});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    UserInfoData? user;
    UserInfoGroup? group;
    UserInfoOrg? organization;
    
    
    if (json.containsKey('user')) {
      user = UserInfoData.fromJson(json['user']);
    }

    if (json.containsKey('group')) {
      group = UserInfoGroup.fromJson(json['group']);
    }

    if (json.containsKey('organization')) {
      organization = UserInfoOrg.fromJson(json['organization']);
    }

    return UserInfo(
      islogin: json['islogin'],
      user: user,
      group: group,
      organization: organization
    );
  }
}