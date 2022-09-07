class VehicleDriver {
  int? id;
  int? user_id;
  String? description;

  VehicleDriver({this.id, this.user_id, this.description});

  VehicleDriver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['user_id'] = user_id;
    data['description'] = description;

    return data;
  }
}