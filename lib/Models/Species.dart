/// Species
class Species {
  int? id;
  int? orgid;
  String? name;
  int? isdeleted;

  Species({this.id, this.orgid, this.name, this.isdeleted});

  /// fromJson
  Species.fromJson(Map<String, dynamic> json) {
    orgid = json['id'];
    name = json['name'];
    isdeleted = json['isdeleted'];
  }

  /// fromDbJson
  Species.fromDbJson(Map<String, dynamic> json) {
    id = json['id'];
    orgid = json['orgid'];
    name = json['name'];
    isdeleted = json['isdeleted'];
  }

  /// toJson
  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = orgid;
    }

    data['name'] = name;
    data['isdeleted'] = isdeleted;

    return data;
  }

  /// toDbJson
  Map<String, dynamic> toDbJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['orgid'] = orgid;
    data['name'] = name;
    data['isdeleted'] = isdeleted;

    return data;
  }
}