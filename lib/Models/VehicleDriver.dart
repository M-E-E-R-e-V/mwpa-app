class VehicleDriver {
  int? id;
  int? user_id;
  String? description;
  String? username;

  VehicleDriver({this.id, this.user_id, this.description, this.username});

  VehicleDriver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    description = json['description'];

    if (json['username'] is String) {
      username = json['username'];
    } else {
      username = "${json['username']}";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['user_id'] = user_id;
    data['description'] = description;
    data['username'] = username;

    return data;
  }
  
}