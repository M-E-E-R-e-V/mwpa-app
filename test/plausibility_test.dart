import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilPlausibility.dart';

Sighting _s({String? date = '2026-11-05', String? start = '09:00', String? end = '13:00', String? from, String? until}) =>
    Sighting(unid: '', date: date, tour_start: start, tour_end: end, duration_from: from, duration_until: until);

final _now = DateTime(2026, 11, 6, 10);

void main() {
  group('checkTimes', () {
    test('plausible sighting: no hint', () {
      expect(UtilPlausibility.checkTimes(_s(from: '10:00', until: '10:30'), _now), isEmpty);
      expect(UtilPlausibility.checkTimes(_s(start: null, end: null), _now), isEmpty);
    });

    test('sighting outside the tour times', () {
      expect(UtilPlausibility.checkTimes(_s(from: '08:30'), _now), [SightingCheck.beginBeforeTourStart]);
      expect(UtilPlausibility.checkTimes(_s(from: '13:30'), _now), [SightingCheck.beginAfterTourEnd]);
    });

    test('end before begin', () {
      expect(UtilPlausibility.checkTimes(_s(from: '10:30', until: '10:00'), _now), [SightingCheck.endBeforeBegin]);
    });

    test('tour over midnight: one hint, no checks against the tour times', () {
      expect(UtilPlausibility.checkTimes(_s(start: '22:00', end: '01:00', from: '23:30'), _now),
          [SightingCheck.tourEndBeforeStart]);
    });

    test('date in the future, today is fine', () {
      expect(UtilPlausibility.checkTimes(_s(date: '2026-11-07'), _now), [SightingCheck.dateInFuture]);
      expect(UtilPlausibility.checkTimes(_s(date: '2026-11-06'), _now), isEmpty);
    });
  });

  group('checkTrack', () {
    const pos = '{"latitude": 28.00, "longitude": -16.0}';
    final at = DateTime(2026, 11, 5, 10, 15);

    Future<SightingCheckResult?> run(Map<int, UtilLocationDouble> pointsByMinute, {String? json = pos}) {
      return UtilPlausibility.checkTrack(
        check: SightingCheck.beginFarFromTrack,
        positionJson: json,
        at: at,
        trackAt: (m) async => pointsByMinute[m.minute],
      );
    }

    test('close to the route: no hint', () async {
      expect(await run({15: UtilLocationDouble(lat: 28.005, lon: -16.0)}), isNull);
    });

    test('far from the route: hint with distance', () async {
      final r = await run({15: UtilLocationDouble(lat: 28.02, lon: -16.0)});
      expect(r?.check, SightingCheck.beginFarFromTrack);
      expect(r!.meters, closeTo(2224, 5));
    });

    test('uses a point up to 2 minutes away', () async {
      expect((await run({17: UtilLocationDouble(lat: 28.02, lon: -16.0)}))?.meters, isNotNull);
      expect(await run({18: UtilLocationDouble(lat: 28.02, lon: -16.0)}), isNull);
    });

    test('no position or unreadable position: no hint', () async {
      final far = {15: UtilLocationDouble(lat: 28.02, lon: -16.0)};
      expect(await run(far, json: null), isNull);
      expect(await run(far, json: 'null'), isNull);
      expect(await run(far, json: 'broken'), isNull);
    });
  });

  test('stored UTC date is read as local date', () {
    final localMidnight = DateTime(2026, 11, 7);
    final stored = localMidnight.toUtc().toString();

    expect(UtilPlausibility.timeOn(stored, '10:15'), DateTime(2026, 11, 7, 10, 15));
    expect(UtilPlausibility.checkTimes(_s(date: stored), _now), [SightingCheck.dateInFuture]);
    expect(UtilPlausibility.checkTimes(_s(date: DateTime(2026, 11, 6).toUtc().toString()), _now), isEmpty);
  });

  test('timeOn combines date and HH:mm', () {
    expect(UtilPlausibility.timeOn('2026-11-05', '10:15'), DateTime(2026, 11, 5, 10, 15));
    expect(UtilPlausibility.timeOn('2026-11-05', ''), isNull);
    expect(UtilPlausibility.timeOn(null, '10:15'), isNull);
  });
  group('checkValues', () {
    List<SightingCheck> run(Sighting s, {double? coast}) =>
        UtilPlausibility.checkValues(s, coastMetersAtBegin: coast).map((r) => r.check).toList();

    test('plausible values: no hint', () {
      expect(run(Sighting(unid: '', species_count: 3, calves: 1, subgroups: 1, duration_from: '10:00', duration_until: '11:30')), isEmpty);
      expect(run(Sighting(unid: '')), isEmpty);
    });

    test('young or subgroups with a single animal', () {
      expect(run(Sighting(unid: '', species_count: 1, newborns: 1)), [SightingCheck.youngButSingleAnimal]);
      expect(run(Sighting(unid: '', species_count: 1, subgroups: 1)), [SightingCheck.subgroupsButSingleAnimal]);
      // no / unknown are fine
      expect(run(Sighting(unid: '', species_count: 1, calves: 0, juveniles: -1, subgroups: -1)), isEmpty);
    });

    test('sighting longer than 3 hours', () {
      expect(run(Sighting(unid: '', duration_from: '09:00', duration_until: '12:01')), [SightingCheck.longSighting]);
      expect(run(Sighting(unid: '', duration_from: '09:00', duration_until: '12:00')), isEmpty);
      // end before begin is the time check's hint
      expect(run(Sighting(unid: '', duration_from: '12:00', duration_until: '08:00')), isEmpty);
    });

    test('typed distance to the coast differs from the begin position', () {
      final results = UtilPlausibility.checkValues(Sighting(unid: '', distance_coast: '9000'), coastMetersAtBegin: 3000);
      expect(results.single.check, SightingCheck.distanceCoastDiffers);
      expect(results.single.meters, 3000);
      // within 1 nm or 50 %
      expect(run(Sighting(unid: '', distance_coast: '1500'), coast: 3000), isEmpty);
      expect(run(Sighting(unid: '', distance_coast: '25000'), coast: 20000), isEmpty);
      // estimated on purpose, no begin position, no value
      expect(run(Sighting(unid: '', distance_coast: '9000', distance_coast_estimation_gps: 1), coast: 3000), isEmpty);
      expect(run(Sighting(unid: '', distance_coast: '9000')), isEmpty);
      expect(run(Sighting(unid: ''), coast: 3000), isEmpty);
    });
  });

  group('checkSpeciesArea', () {
    String pos(double lat, double lon) => '{"latitude": $lat, "longitude": $lon}';

    // earlier sightings near 28.0 / -17.3, all species 5
    List<Sighting> others(int n, {int species = 5, double lat = 28.0}) => [
          for (var i = 0; i < n; i++)
            Sighting(unid: '', id: i + 100, species_id: species, location_begin: pos(lat + i * 0.0001, -17.3)),
        ];

    Sighting s(int species, {double lat = 28.0}) => Sighting(unid: '', species_id: species, location_begin: pos(lat, -17.3));

    test('species never recorded among enough nearby sightings', () {
      expect(UtilPlausibility.checkSpeciesArea(s(7), others(30))?.check, SightingCheck.unusualSpeciesInArea);
    });

    test('known species, too few nearby sightings or far away: no hint', () {
      expect(UtilPlausibility.checkSpeciesArea(s(5), others(30)), isNull);
      expect(UtilPlausibility.checkSpeciesArea(s(7), others(29)), isNull);
      // ~33 km north
      expect(UtilPlausibility.checkSpeciesArea(s(7, lat: 28.3), others(30)), isNull);
      expect(UtilPlausibility.checkSpeciesArea(Sighting(unid: '', species_id: 7), others(30)), isNull);
    });

    test('the edited sighting itself does not count', () {
      final list = [...others(30), Sighting(unid: '', id: 1, species_id: 7, location_begin: pos(28.0, -17.3))];
      expect(UtilPlausibility.checkSpeciesArea(s(7), list), isNull);
      expect(UtilPlausibility.checkSpeciesArea(s(7), list, excludeId: 1)?.check, SightingCheck.unusualSpeciesInArea);
    });
  });
}
