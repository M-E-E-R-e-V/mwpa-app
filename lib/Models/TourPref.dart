import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

class TourPref {
  int? vehicle_id;
  int? vehicle_driver_id;
  String? beaufort_wind;
  String? date;
  String? tour_start;
  String? tour_end;
  int? set_end_tour;
  int? use_home_area;

  TourPref({
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
    this.beaufort_wind,
    this.tour_start,
    this.tour_end,
    this.set_end_tour,
    this.use_home_area
  });

  TourPref.fromJson(Map<String, dynamic> json) {
    vehicle_id = UtilCheckJson.checkValue(json['vehicle_id'], UtilCheckJsonTypes.int);
    vehicle_driver_id = UtilCheckJson.checkValue(json['vehicle_driver_id'], UtilCheckJsonTypes.int);
    beaufort_wind = UtilCheckJson.checkValue(json['beaufort_wind'], UtilCheckJsonTypes.string);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
    tour_start = UtilCheckJson.checkValue(json['tour_start'], UtilCheckJsonTypes.string);
    tour_end = UtilCheckJson.checkValue(json['tour_end'], UtilCheckJsonTypes.string);
    set_end_tour = UtilCheckJson.checkValue(json['set_end_tour'], UtilCheckJsonTypes.int);
    use_home_area = UtilCheckJson.checkValue(json['use_home_area'], UtilCheckJsonTypes.int);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['beaufort_wind'] = beaufort_wind;

    try {
      if (date!.contains('/')) {
        var parts = date!.split('/');

        date = '${parts[2]}-${parts[0]}-${parts[1]}';
      }

      DateTime tDate = DateTime.parse(date!);
      date = DateFormat("yyyy-MM-dd").format(tDate.toLocal());
    } catch(e) {
      if (kDebugMode) {
        print('TourPref::toJson: date parsing error:');
        print(e);
      }
    }

    data['date'] = date;
    data['tour_start'] = tour_start;
    data['tour_end'] = tour_end;
    data['set_end_tour'] = set_end_tour ?? 0;
    data['use_home_area'] = use_home_area ?? 0;

    return data;
  }
}