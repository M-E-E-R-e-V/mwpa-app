class EncounterCategorie {
  int? id;
  String? name;
  int? isdeleted;

  EncounterCategorie({this.id, this.name, this.isdeleted});

  EncounterCategorie.fromJson(Map<String, dynamic> json) {
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