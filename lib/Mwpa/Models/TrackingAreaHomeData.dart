
import 'package:mwpaapp/Util/UtilLocation.dart';

/// TrackingAreaHomeData
class TrackingAreaHomeData {
  final List<UtilLocationDouble> coordinates;
  final int organization_id;
  final int create_datetime;
  final int update_datetime;

  const TrackingAreaHomeData({
    required this.coordinates,
    required this.organization_id,
    required this.create_datetime,
    required this.update_datetime
  });

  factory TrackingAreaHomeData.fromJson(Map<String, dynamic> json) {
    List<UtilLocationDouble> coordinates = [];
    int organizationId = 0;
    int createDatetime = 0;
    int updateDatetime = 0;

    if (json.containsKey('coordinates')) {
      List<dynamic> vcoordinates = json['coordinates'];

      for (var element in vcoordinates) {
        coordinates.add(UtilLocationDouble(lon: element[0], lat: element[1]));
      }
    }

    if (json.containsKey('organization_id')) {
      organizationId = json['organization_id'];
    }

    if (json.containsKey('create_datetime')) {
      createDatetime = json['create_datetime'];
    }

    if (json.containsKey('update_datetime')) {
      createDatetime = json['update_datetime'];
    }

    return TrackingAreaHomeData(
      coordinates: coordinates,
      organization_id: organizationId,
      create_datetime: createDatetime,
      update_datetime: updateDatetime
    );
  }

}