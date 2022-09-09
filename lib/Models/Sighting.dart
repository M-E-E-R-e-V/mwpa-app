class Sighting {

  int? id;
  String? unid;
  int? vehicle_id;
  int? vehicle_driver_id;
  String? date;
  String? tour_start;
  String? tour_end;
  String? duration_from;
  String? duration_until;
  String? location_begin;
  String? location_end;
  int? species_id;

  Sighting({
    required this.unid,
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
    this.tour_start,
    this.tour_end,
    this.duration_from,
    this.duration_until,
    this.location_begin,
    this.location_end,
    this.species_id
  });

  Sighting.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unid = json['unid'];
    vehicle_id = json['vehicle_id'];
    vehicle_driver_id = json['vehicle_driver_id'];
    date = json['date'];
    tour_start = json['tour_start'];
    tour_end = json['tour_end'];
    duration_from = json['duration_from'];
    duration_until = json['duration_until'];
    species_id = json['species_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['unid'] = unid;
    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['date'] = date;
    data['species_id'] = species_id;

    return data;
  }
}