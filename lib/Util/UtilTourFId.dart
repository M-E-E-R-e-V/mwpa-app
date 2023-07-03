import 'package:intl/intl.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';

/// UtilTourFid
class UtilTourFid {

  /// createTTourFId
  static createTTourFId(TourPref tour) {
    DateTime tDate = DateTime.parse("${tour.date}");
    var date = DateFormat("yyyy-MM-dd").format(tDate.toLocal());

    return "${tour.vehicle_id}-${tour.vehicle_driver_id}-$date-${tour.tour_start}";
  }

  /// createSTourFId
  static createSTourFId(Sighting sighting) {
    DateTime tDate = DateTime.parse("${sighting.date}");
    var date = DateFormat("yyyy-MM-dd").format(tDate.toLocal());

    return "${sighting.vehicle_id}-${sighting.vehicle_driver_id}-$date-${sighting.tour_start}";
  }

  /// convertTourFid
  static convertTourFid(String fTourId) {
    if (fTourId.contains(' ')) {
      var parts = fTourId.split(' ');

      var newFTourId = parts[0];

      var parts2 = fTourId.split('Z');

      newFTourId += parts2[1];

      return newFTourId;
    }

    return fTourId;
  }
}