class Species {
  int? id;
  String? name;
  int? isdeleted;

  Species({this.id, this.name, this.isdeleted});

  Species.fromJson(Map<String, dynamic> json) {
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