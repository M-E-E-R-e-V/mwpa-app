
/// VehicleDriver
class VehicleDriver {
  int? id;
  int? userId;
  String? description;
  String? username;
  int? isdeleted;

  /// VehicleDriver
  VehicleDriver({this.id, this.userId, this.description, this.username, this.isdeleted});

  /// fromJson
  VehicleDriver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    description = json['description'];

    if (json['username'] is String) {
      username = json['username'];
    } else {
      username = "${json['username']}";
    }

    isdeleted = json['isdeleted'];
  }

  /// toJson
  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['user_id'] = userId;
    data['description'] = description;
    data['username'] = username;
    data['isdeleted'] = isdeleted;

    return data;
  }
  
}