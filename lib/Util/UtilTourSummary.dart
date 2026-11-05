import 'dart:convert';
import 'dart:math' as math;

import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';

/// TourSummary - one tour of the sightings list: date, start/end time and
/// its sightings (in list order). The distance comes from the tracking
/// points and is computed separately ([UtilTourSummary.routeMeters]).
class TourSummary {
  final String tourFid;
  final String? date;
  final String? start;

  /// latest end time of the tour's sightings ("" / null: not ended yet)
  final String? end;
  final List<Sighting> sightings;

  const TourSummary({
    required this.tourFid,
    required this.date,
    required this.start,
    required this.end,
    required this.sightings,
  });

  /// duration - start to end (over midnight if the end is earlier), null if
  /// one of them is missing
  Duration? get duration {
    final s = UtilTourSummary.minutesOfDay(start);
    final e = UtilTourSummary.minutesOfDay(end);

    if (s == null || e == null) {
      return null;
    }

    final minutes = e >= s ? e - s : e + 24 * 60 - s;
    return Duration(minutes: minutes);
  }

  /// animals - total count of animals over all sightings
  int get animals => sightings.fold(0, (sum, s) => sum + math.max(s.species_count ?? 0, 0));

  /// speciesCounts - number of sightings per display name, most first;
  /// [nameOf] gives the name of a sighting (null: unknown species)
  List<MapEntry<String, int>> speciesCounts(String? Function(Sighting) nameOf) {
    final counts = <String, int>{};

    for (final s in sightings) {
      final name = nameOf(s);

      if (name != null) {
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }

    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
}

/// UtilTourSummary - groups sightings into tours and measures routes
class UtilTourSummary {
  static const double metersPerNauticalMile = 1852;

  /// jumps above this between two points are GPS errors, not travel
  static const double maxStepMeters = 5000;

  /// group - one summary per tour, in the order the tours first appear in
  /// [sightings] (the list is newest first)
  static List<TourSummary> group(List<Sighting> sightings) {
    final byFid = <String, List<Sighting>>{};

    for (final s in sightings) {
      String fid;

      try {
        fid = UtilTourFid.createSTourFId(s);
      } catch (_) {
        // no valid date: own group per sighting
        fid = 'sighting-${s.id}';
      }

      byFid.putIfAbsent(fid, () => []).add(s);
    }

    return [
      for (final entry in byFid.entries)
        TourSummary(
          tourFid: entry.key,
          date: entry.value.first.date,
          start: entry.value.first.tour_start,
          end: latestEnd(entry.value.map((s) => s.tour_end)),
          sightings: entry.value,
        ),
    ];
  }

  /// latestEnd - the latest of the set end times (HH:mm) or null
  static String? latestEnd(Iterable<String?> ends) {
    String? best;
    int? bestMinutes;

    for (final e in ends) {
      final m = minutesOfDay(e);

      if (m != null && (bestMinutes == null || m > bestMinutes)) {
        best = e;
        bestMinutes = m;
      }
    }

    return best;
  }

  /// minutesOfDay - "09:30" -> 570, null for anything else
  static int? minutesOfDay(String? time) {
    if (time == null) return null;

    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(time.trim());

    if (match == null) return null;

    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);

    if (h > 23 || m > 59) return null;

    return h * 60 + m;
  }

  /// pointsFromJson - tracking point locations (Position JSON) as lat/lon
  static List<UtilLocationDouble> pointsFromJson(Iterable<String> locations) {
    final points = <UtilLocationDouble>[];

    for (final json in locations) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        points.add(UtilLocationDouble(
          lat: (map['latitude'] as num).toDouble(),
          lon: (map['longitude'] as num).toDouble(),
        ));
      } catch (_) {
        // unreadable point: skip
      }
    }

    return points;
  }

  /// routeMeters - length of the route (great circle per step); single
  /// jumps above [maxStepMeters] are ignored as GPS errors
  static double routeMeters(List<UtilLocationDouble> points) {
    var meters = 0.0;

    for (var i = 1; i < points.length; i++) {
      final step = distanceMeters(points[i - 1], points[i]);

      if (step <= maxStepMeters) {
        meters += step;
      }
    }

    return meters;
  }

  /// distanceMeters - haversine distance of two points
  static double distanceMeters(UtilLocationDouble a, UtilLocationDouble b) {
    const earthRadius = 6371000.0;
    double rad(double deg) => deg * math.pi / 180;

    final dLat = rad(b.lat - a.lat);
    final dLon = rad(b.lon - a.lon);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);

    return 2 * earthRadius * math.asin(math.sqrt(h));
  }
}
