
class UserInfoGroup {
  final int id;
  final String name;

  const UserInfoGroup({required this.id, required this.name});

  factory UserInfoGroup.fromJson(Map<String, dynamic> json) {
    return UserInfoGroup(
      id: json['id'],
      name: json['name']
    );
  }

}