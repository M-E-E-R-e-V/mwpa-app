import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';

/// TourTracking
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

  /// fromJson
  TourTracking.fromJson(Map<String, dynamic> json) {
    uuid = UtilCheckJson.checkValue(json['uuid'], UtilCheckJsonTypes.string);
    tour_fid = UtilCheckJson.checkValue(json['tour_fid'], UtilCheckJsonTypes.string);
    location = UtilCheckJson.checkValue(json['location'], UtilCheckJsonTypes.string);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
  }

  /// toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (tour_fid != null) {
      tour_fid = UtilTourFid.convertTourFid(tour_fid!);
    }

    try {
      if (date!.contains('/')) {
        var parts = date!.split('/');

        date = '${parts[2]}-${parts[0]}-${parts[1]}';
      }

      DateTime tDate = DateTime.parse(date!);
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(tDate.toLocal());
    } catch(e) {
      if (kDebugMode) {
        print('TourTracking::toJson: date parsing error:');
        print(e);
      }
    }

    data['uuid'] = uuid;
    data['tour_fid'] = tour_fid;
    data['location'] = location;
    data['date'] = date;

    return data;
  }
}