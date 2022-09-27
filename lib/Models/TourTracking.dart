import 'package:mwpaapp/Util/UtilCheckJson.dart';

class TourTracking {
  String? uuid;
  String? tour_fid;
  String? location;
  String? date;

  TourTracking({
    this.uuid,
    this.tour_fid,
    this.location,
    this.date
  });

  TourTracking.fromJson(Map<String, dynamic> json) {
    uuid = UtilCheckJson.checkValue(json['uuid'], UtilCheckJsonTypes.string);
    tour_fid = UtilCheckJson.checkValue(json['tour_fid'], UtilCheckJsonTypes.string);
    location = UtilCheckJson.checkValue(json['location'], UtilCheckJsonTypes.string);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['uuid'] = uuid;
    data['tour_fid'] = tour_fid;
    data['location'] = location;
    data['date'] = date;

    return data;
  }
}