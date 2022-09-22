import 'package:mwpaapp/Util/UtilCheckJson.dart';

class TourPref {
  int? vehicle_id;
  int? vehicle_driver_id;
  int? beaufort_wind;
  String? date;
  String? tour_start;
  String? tour_end;

  TourPref({
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
    this.beaufort_wind,
    this.tour_start,
    this.tour_end,
  });

  TourPref.fromJson(Map<String, dynamic> json) {
    vehicle_id = UtilCheckJson.checkValue(json['vehicle_id'], UtilCheckJsonTypes.int);
    vehicle_driver_id = UtilCheckJson.checkValue(json['vehicle_driver_id'], UtilCheckJsonTypes.int);
    beaufort_wind = UtilCheckJson.checkValue(json['beaufort_wind'], UtilCheckJsonTypes.int);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
    tour_start = UtilCheckJson.checkValue(json['tour_start'], UtilCheckJsonTypes.string);
    tour_end = UtilCheckJson.checkValue(json['tour_end'], UtilCheckJsonTypes.string);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['beaufort_wind'] = beaufort_wind;
    data['date'] = date;
    data['tour_start'] = tour_start;
    data['tour_end'] = tour_end;

    return data;
  }
}