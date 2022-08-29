class UserInfoData {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;

  const UserInfoData({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isAdmin: json['isAdmin']
    );
  }
}