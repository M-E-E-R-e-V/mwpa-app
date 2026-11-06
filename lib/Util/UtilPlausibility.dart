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
  endFarFromTrack(SightingField.endPosition);

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
