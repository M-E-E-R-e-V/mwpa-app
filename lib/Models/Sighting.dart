class Sighting {

  int? id;
  String? unid;
  int? vehicle_id;
  int? vehicle_driver_id;
  String? date;

  Sighting({
    required this.unid,
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
  });

  Sighting.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unid = json['unid'];
    vehicle_id = json['vehicle_id'];
    vehicle_driver_id = json['vehicle_driver_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['unid'] = unid;
    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['date'] = date;

    return data;
  }
}