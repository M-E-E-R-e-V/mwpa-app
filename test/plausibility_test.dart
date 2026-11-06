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
}
