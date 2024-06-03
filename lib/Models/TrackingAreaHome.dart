import 'package:mwpaapp/Util/UtilCheckJson.dart';

class TrackingAreaHome {
  String? uuid;
  int? orgid;
  int? cord_index;
  String? lon;
  String? lat;
  int? update_datetime;

  TrackingAreaHome({
    this.uuid,
    this.orgid,
    this.cord_index,
    this.lon,
    this.lat,
    this.update_datetime
  });

  /// fromJson
  TrackingAreaHome.fromJson(Map<String, dynamic> json) {
    uuid = UtilCheckJson.checkValue(json['uuid'], UtilCheckJsonTypes.string);
    orgid = UtilCheckJson.checkValue(json['orgid'], UtilCheckJsonTypes.int);
    cord_index = UtilCheckJson.checkValue(json['cord_index'], UtilCheckJsonTypes.int);
    lon = UtilCheckJson.checkValue(json['lon'], UtilCheckJsonTypes.string);
    lat = UtilCheckJson.checkValue(json['lat'], UtilCheckJsonTypes.string);
    update_datetime = UtilCheckJson.checkValue(json['update_datetime'], UtilCheckJsonTypes.int);
  }

  /// toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['uuid'] = uuid;
    data['orgid'] = orgid;
    data['cord_index'] = cord_index;
    data['lon'] = lon;
    data['lat'] = lat;
    data['update_datetime'] = update_datetime;

    return data;
  }
}