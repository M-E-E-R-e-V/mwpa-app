class Vehicle {
  int? id;
  String? name;
  int? isdeleted;

  Vehicle({this.id, this.name, this.isdeleted});

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isdeleted = json['isdeleted'];
  }

  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['name'] = name;
    data['isdeleted'] = isdeleted;

    return data;
  }
}