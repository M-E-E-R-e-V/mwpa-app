import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';

/// UtilTourFid
class UtilTourFid {

  /// createTTourFId
  static createTTourFId(TourPref tour) {
    return "${tour.vehicle_id}-${tour.vehicle_driver_id}-${tour.date}-${tour.tour_start}";
  }

  /// createSTourFId
  static createSTourFId(Sighting sighting) {
    return "${sighting.vehicle_id}-${sighting.vehicle_driver_id}-${sighting.date}-${sighting.tour_start}";
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