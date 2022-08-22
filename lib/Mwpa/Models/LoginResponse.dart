
class LoginResponse {
  final bool success;
  final String? error;

  const LoginResponse({required this.success, this.error});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      error: json['error']
    );
  }
}