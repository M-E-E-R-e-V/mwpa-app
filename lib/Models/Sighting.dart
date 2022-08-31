class Sighting {

  String uid;
  int? vehicle_id;
  int? vehicle_driver_id;
  String? date;

  Sighting({
    required this.uid,
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['uid'] = uid;
    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['date'] = date;

    return data;
  }
}