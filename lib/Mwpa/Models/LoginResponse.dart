/// LoginResponse - answer of the login endpoints; [deviceToken] is only sent
/// by /mobile/quickconnect of servers that support the device token login
/// (older servers leave it out)
class LoginResponse {
  final bool success;
  final String? error;
  final String? deviceToken;

  const LoginResponse({required this.success, this.error, this.deviceToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['device_token'];

    return LoginResponse(
      success: json['success'],
      error: json['error'],
      deviceToken: token is String && token.isNotEmpty ? token : null,
    );
  }
}
