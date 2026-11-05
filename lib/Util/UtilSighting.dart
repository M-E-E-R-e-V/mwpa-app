
import 'package:flutter/material.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';

/// Sighting Helper
class UtilSighting {

  /// set the End Tour date and save all sightings
  static Future<void> setCurrentEndTour(SightingController sightingController, String tourFid) async {
    TimeOfDay timeValue = TimeOfDay.now();
    var hour = "${timeValue.hour}";
    var min = "${timeValue.minute}";

    if (timeValue.hour < 10) {
      hour = "0${timeValue.hour}";
    }

    if (timeValue.minute < 10) {
      min = "0${timeValue.minute}";
    }

    var tourEndTime = "$hour:$min";

    await sightingController.updateSightingEndtour(
        tourFid,
        tourEndTime
    );
  }


  /// displayName - what a sighting is called in lists: the species name
  /// ([speciesName] from the species list), else "other" (quick entries),
  /// else the note; only the common name ("Fin Whale, Finnwal (...)" ->
  /// "Fin Whale"). Null if nothing is set.
  static String? displayName(Sighting sighting, String? speciesName) {
    bool isSet(String? v) => v != null && v.trim() != '' && v.trim() != 'null';

    final name = isSet(speciesName)
        ? speciesName!
        : isSet(sighting.other)
            ? sighting.other!.trim()
            : isSet(sighting.note)
                ? sighting.note!.trim()
                : null;

    return name?.split(',')[0];
  }

  /// shortSightingTour - tour a quick entry ("Add Tortoise") belongs to, or
  /// null when there is no usable tour: no default tour, no date or start
  /// time (would give a tour_fid like "1-43-2026-05-26-"), or in home-area
  /// mode while the boat is still in the home area.
  static TourPref? shortSightingTour({TourPref? prefTour, TourPref? homeAreaTour}) {
    if (prefTour == null) {
      return null;
    }

    var tour = prefTour;

    if ((prefTour.use_home_area ?? 0) >= 1) {
      if (homeAreaTour == null) {
        return null;
      }

      tour = TourPref(
        vehicle_id: prefTour.vehicle_id,
        vehicle_driver_id: prefTour.vehicle_driver_id,
        beaufort_wind: prefTour.beaufort_wind,
        date: homeAreaTour.date,
        tour_start: homeAreaTour.tour_start,
        tour_end: "",
        set_end_tour: prefTour.set_end_tour,
        use_home_area: prefTour.use_home_area,
      );
    }

    if ((tour.date ?? "").isEmpty || (tour.tour_start ?? "").isEmpty || tour.vehicle_id == null) {
      return null;
    }

    return tour;
  }
}
