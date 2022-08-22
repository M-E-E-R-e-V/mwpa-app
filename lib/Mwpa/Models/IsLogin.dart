
class IsLogin {
  final bool status;

  const IsLogin({required this.status});

  factory IsLogin.fromJson(Map<String, dynamic> json) {
    return IsLogin(
      status: json['status']
    );
  }
}