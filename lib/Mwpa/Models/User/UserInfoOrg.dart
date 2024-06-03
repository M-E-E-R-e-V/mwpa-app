
class UserInfoOrg {
  final int id;
  final String name;

  const UserInfoOrg({required this.id, required this.name});

  factory UserInfoOrg.fromJson(Map<String, dynamic> json) {
    return UserInfoOrg(
        id: json['id'],
        name: json['name']
    );
  }
}