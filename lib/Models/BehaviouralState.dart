class BehaviouralState {
  int? id;
  String? name;
  String? description;
  int? isdeleted;

  BehaviouralState({this.id, this.name, this.description, this.isdeleted});

  BehaviouralState.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    isdeleted = json['isdeleted'];
  }

  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['name'] = name;
    data['description'] = description;
    data['isdeleted'] = isdeleted;

    return data;
  }
}