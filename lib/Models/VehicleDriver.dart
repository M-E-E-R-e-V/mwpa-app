class VehicleDriver {
  int? id;
  int? user_id;
  String? description;
  String? username;
  int? isdeleted;

  VehicleDriver({this.id, this.user_id, this.description, this.username, this.isdeleted});

  VehicleDriver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    description = json['description'];

    if (json['username'] is String) {
      username = json['username'];
    } else {
      username = "${json['username']}";
    }

    isdeleted = json['isdeleted'];
  }

  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['user_id'] = user_id;
    data['description'] = description;
    data['username'] = username;
    data['isdeleted'] = isdeleted;

    return data;
  }
  
}