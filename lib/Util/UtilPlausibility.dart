import 'dart:convert';

import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilTourSummary.dart';

/// SightingCheck - a value that looks wrong; only a hint, saving is never
/// blocked. [field] is the input the hint points to.
enum SightingCheck {
  tourEndBeforeStart(SightingField.tourEnd),
  beginBeforeTourStart(SightingField.beginTime),
  beginAfterTourEnd(SightingField.beginTime),
  endBeforeBegin(SightingField.beginTime),
  dateInFuture(SightingField.date),
  beginFarFromTrack(SightingField.beginPosition),
  endFarFromTrack(SightingField.endPosition),
  youngButSingleAnimal(SightingField.count),
  subgroupsButSingleAnimal(SightingField.count),
  longSighting(SightingField.endTime),
  distanceCoastDiffers(SightingField.distanceCoast),
  unusualSpeciesInArea(SightingField.species);

  final SightingField field;

  const SightingCheck(this.field);
}

/// SightingCheckResult - a failed check; [meters] for the route checks
class SightingCheckResult {
  final SightingCheck check;
  final int? meters;

  const SightingCheckResult(this.check, [this.meters]);
}

/// UtilPlausibility - plausibility checks of a sighting (times, date and the
/// positions compared with the recorded tour route)
class UtilPlausibility {
  /// a position further away from the boat's route is suspicious (GPS
  /// accuracy, animals at a distance and drift are below this)
  static const int maxTrackDistanceMeters = 1000;

  /// minutes around the sighting time searched for a tracking point
  static const List<int> trackSearchOffsets = [0, -1, 1, -2, 2];

  /// a sighting longer than this is unusual (typing error in a time?)
  static const int longSightingMinutes = 180;

  /// a typed distance to the coast differs from the one of the begin
  /// position by more than this (and [coastDiffRatio] of it)
  static const double coastDiffMinMeters = 1852;
  static const double coastDiffRatio = 0.5;

  /// species check: earlier sightings within this radius, at least
  /// [speciesAreaMinSightings] of them, none of the species
  static const double speciesAreaRadiusMeters = 20000;
  static const int speciesAreaMinSightings = 30;

  /// checkValues - counts, duration and distance to the coast (no DB
  /// needed); [coastMetersAtBegin] is the distance to the coast of the begin
  /// position, null without one
  static List<SightingCheckResult> checkValues(Sighting s, {double? coastMetersAtBegin}) {
    final results = <SightingCheckResult>[];

    // YesNoUnknown: 1 = yes
    if (s.species_count == 1) {
      if (s.calves == 1 || s.juveniles == 1 || s.newborns == 1) {
        results.add(const SightingCheckResult(SightingCheck.youngButSingleAnimal));
      }

      if (s.subgroups == 1) {
        results.add(const SightingCheckResult(SightingCheck.subgroupsButSingleAnimal));
      }
    }

    final begin = UtilTourSummary.minutesOfDay(s.duration_from);
    final end = UtilTourSummary.minutesOfDay(s.duration_until);

    // end before begin is its own hint
    if (begin != null && end != null && end >= begin && end - begin > longSightingMinutes) {
      results.add(const SightingCheckResult(SightingCheck.longSighting));
    }

    // switch "estimation (no GPS)" on = the observer estimated it on purpose
    final typed = double.tryParse(s.distance_coast ?? '');

    if (s.distance_coast_estimation_gps != 1 && coastMetersAtBegin != null && typed != null) {
      final limit = coastMetersAtBegin * coastDiffRatio;

      if ((typed - coastMetersAtBegin).abs() > (limit > coastDiffMinMeters ? limit : coastDiffMinMeters)) {
        results.add(SightingCheckResult(SightingCheck.distanceCoastDiffers, coastMetersAtBegin.round()));
      }
    }

    return results;
  }

  /// checkSpeciesArea - the species of [s] was never recorded in the earlier
  /// sightings around its begin position, although there are enough of them
  /// ([excludeId] = the sighting itself when it is edited). Species ids are
  /// server ids (orgid) on both sides.
  static SightingCheckResult? checkSpeciesArea(Sighting s, Iterable<Sighting> others, {int? excludeId}) {
    final species = s.species_id;
    final position = positionOf(s.location_begin);

    if (species == null || species <= 0 || position == null) {
      return null;
    }

    var nearby = 0;

    for (final other in others) {
      if (other.species_id == null || (excludeId != null && other.id == excludeId)) {
        continue;
      }

      final p = positionOf(other.location_begin);

      if (p == null || UtilTourSummary.distanceMeters(position, p) > speciesAreaRadiusMeters) {
        continue;
      }

      if (other.species_id == species) {
        return null;
      }

      nearby++;
    }

    return nearby >= speciesAreaMinSightings ? const SightingCheckResult(SightingCheck.unusualSpeciesInArea) : null;
  }

  /// checkTimes - date and time checks (no DB needed)
  static List<SightingCheck> checkTimes(Sighting s, DateTime now) {
    final tourStart = UtilTourSummary.minutesOfDay(s.tour_start);
    final tourEnd = UtilTourSummary.minutesOfDay(s.tour_end);
    final begin = UtilTourSummary.minutesOfDay(s.duration_from);
    final end = UtilTourSummary.minutesOfDay(s.duration_until);

    final checks = <SightingCheck>[];

    // tour over midnight is possible but rare: hint, and the checks
    // against the tour times are skipped
    final tourOverMidnight = tourStart != null && tourEnd != null && tourEnd < tourStart;

    if (tourOverMidnight) {
      checks.add(SightingCheck.tourEndBeforeStart);
    }

    if (begin != null && !tourOverMidnight) {
      if (tourStart != null && begin < tourStart) {
        checks.add(SightingCheck.beginBeforeTourStart);
      }

      if (tourEnd != null && begin > tourEnd) {
        checks.add(SightingCheck.beginAfterTourEnd);
      }
    }

    if (begin != null && end != null && end < begin) {
      checks.add(SightingCheck.endBeforeBegin);
    }

    // stored as UTC ("2026-11-05 23:00:00.000Z" = 6th in Berlin)
    final date = s.date == null ? null : DateTime.tryParse(s.date!)?.toLocal();

    if (date != null && DateTime(date.year, date.month, date.day).isAfter(DateTime(now.year, now.month, now.day))) {
      checks.add(SightingCheck.dateInFuture);
    }

    return checks;
  }

  /// timeOn - date of the sighting with a HH:mm time, null if not set
  static DateTime? timeOn(String? date, String? time) {
    final d = date == null ? null : DateTime.tryParse(date)?.toLocal();
    final m = UtilTourSummary.minutesOfDay(time);

    if (d == null || m == null) {
      return null;
    }

    return DateTime(d.year, d.month, d.day, m ~/ 60, m % 60);
  }

  /// positionOf - lat/lon of a stored position (Position JSON) or null
  static UtilLocationDouble? positionOf(String? json) {
    if (json == null || json.isEmpty || json == 'null') {
      return null;
    }

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;

      return UtilLocationDouble(
        lat: (map['latitude'] as num).toDouble(),
        lon: (map['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  /// checkTrack - distance of [positionJson] to the route point at [at]
  /// ([trackAt] returns the recorded point of one minute or null). Null when
  /// it can't be checked (no position, no time, no point) or is close enough.
  static Future<SightingCheckResult?> checkTrack({
    required SightingCheck check,
    required String? positionJson,
    required DateTime? at,
    required Future<UtilLocationDouble?> Function(DateTime minute) trackAt,
  }) async {
    final position = positionOf(positionJson);

    if (position == null || at == null) {
      return null;
    }

    for (final offset in trackSearchOffsets) {
      final point = await trackAt(at.add(Duration(minutes: offset)));

      if (point != null) {
        final meters = UtilTourSummary.distanceMeters(position, point).round();

        return meters > maxTrackDistanceMeters ? SightingCheckResult(check, meters) : null;
      }
    }

    return null;
  }
}
