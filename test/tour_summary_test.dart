import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilLocation.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourSummary.dart';

Sighting _s(int id, {String start = '09:30', String? end, String date = '2026-11-05', int count = 1, String? other}) =>
    Sighting(
      unid: '',
      id: id,
      vehicle_id: 1,
      vehicle_driver_id: 2,
      date: date,
      tour_start: start,
      tour_end: end,
      species_count: count,
      other: other,
    );

void main() {
  test('group: one summary per tour, order of first appearance', () {
    final tours = UtilTourSummary.group([
      _s(3, start: '14:00', end: '17:00'),
      _s(2, end: '12:10'),
      _s(1, end: '13:05', count: 4),
      _s(0, date: '2026-11-04', start: '10:00'),
    ]);

    expect(tours.length, 3);
    expect(tours[0].start, '14:00');
    expect(tours[1].sightings.map((s) => s.id), [2, 1]);
    expect(tours[1].end, '13:05');
    expect(tours[1].duration, const Duration(hours: 3, minutes: 35));
    expect(tours[1].animals, 5);
    expect(tours[2].end, isNull);
    expect(tours[2].duration, isNull);
  });

  test('duration over midnight', () {
    final t = UtilTourSummary.group([_s(1, start: '22:00', end: '01:30')]).single;
    expect(t.duration, const Duration(hours: 3, minutes: 30));
  });

  test('minutesOfDay accepts HH:mm only', () {
    expect(UtilTourSummary.minutesOfDay('09:30'), 570);
    expect(UtilTourSummary.minutesOfDay('9:05'), 545);
    expect(UtilTourSummary.minutesOfDay(''), isNull);
    expect(UtilTourSummary.minutesOfDay('25:00'), isNull);
    expect(UtilTourSummary.minutesOfDay(null), isNull);
  });

  test('speciesCounts: most seen first, unknown skipped', () {
    final t = UtilTourSummary.group([
      _s(1, other: 'Caretta caretta - Loggerhead sea turtle'),
      _s(2, other: 'Dolphin'),
      _s(3, other: 'Dolphin'),
      _s(4),
    ]).single;

    final counts = t.speciesCounts((s) => UtilSighting.displayName(s, null));
    expect(counts.map((e) => '${e.key}:${e.value}'), ['Dolphin:2', 'Caretta caretta - Loggerhead sea turtle:1']);
  });

  test('displayName: species, then other, then note; common name only', () {
    expect(UtilSighting.displayName(Sighting(unid: '', other: 'x'), 'Fin Whale, Finnwal (Balaenoptera)'), 'Fin Whale');
    expect(UtilSighting.displayName(Sighting(unid: '', other: ' Turtle '), null), 'Turtle');
    expect(UtilSighting.displayName(Sighting(unid: '', other: '', note: 'seen far'), null), 'seen far');
    expect(UtilSighting.displayName(Sighting(unid: '', other: 'null'), null), isNull);
  });

  test('routeMeters: sums the steps, ignores GPS jumps', () {
    // 0.01° latitude ~ 1112 m
    final points = [
      UtilLocationDouble(lat: 28.00, lon: -16.0),
      UtilLocationDouble(lat: 28.01, lon: -16.0),
      UtilLocationDouble(lat: 29.00, lon: -16.0), // jump ~110 km
      UtilLocationDouble(lat: 29.01, lon: -16.0),
    ];

    expect(UtilTourSummary.routeMeters(points), closeTo(2224, 5));
    expect(UtilTourSummary.routeMeters(points.take(1).toList()), 0);
  });

  test('pointsFromJson skips unreadable points', () {
    final points = UtilTourSummary.pointsFromJson([
      '{"latitude": 28.1, "longitude": -16.2, "accuracy": 5}',
      'broken',
      '{"latitude": 28.2}',
    ]);

    expect(points.length, 1);
    expect(points.single.lat, 28.1);
  });
}
