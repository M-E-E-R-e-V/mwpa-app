import 'dart:convert';

IsLogin isLoginFromJson(String str) => IsLogin.fromJson(json.decode(str));

String isLoginToJson(IsLogin data) => json.encode(data.toJson());

class IsLogin {
  IsLogin({
    required this.login,
  });

  String login;

  factory IsLogin.fromJson(Map<String, dynamic> json) => IsLogin(
    login: json["login"],
  );

  Map<String, dynamic> toJson() => {
    "login": login,
  };
}
