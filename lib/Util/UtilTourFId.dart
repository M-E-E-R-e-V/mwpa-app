import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';

class UtilTourFid {

  static createTTourFId(TourPref tour) {
    return "${tour.vehicle_id}-${tour.vehicle_driver_id}-${tour.date}-${tour.tour_start}";
  }

  static createSTourFId(Sighting sighting) {
    return "${sighting.vehicle_id}-${sighting.vehicle_driver_id}-${sighting.date}-${sighting.tour_start}";
  }
}