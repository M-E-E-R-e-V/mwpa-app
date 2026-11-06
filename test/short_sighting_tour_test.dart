import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';

TourPref _pref({String start = '08:30', int homeArea = 0}) => TourPref(
      vehicle_id: 1,
      vehicle_driver_id: 43,
      beaufort_wind: '3',
      date: '2026-11-05',
      tour_start: start,
      tour_end: '',
      use_home_area: homeArea,
    );

void main() {
  test('no default tour -> null', () {
    expect(UtilSighting.shortSightingTour(), isNull);
  });

  test('default tour with start time is used', () {
    final tour = UtilSighting.shortSightingTour(prefTour: _pref())!;
    expect(UtilTourFid.createTTourFId(tour), '1-43-2026-11-05-08:30');
  });

  test('missing start time -> null (no truncated tour_fid)', () {
    expect(UtilSighting.shortSightingTour(prefTour: _pref(start: '')), isNull);
  });

  test('home area: null while waiting, running tour once started', () {
    final pref = _pref(start: '', homeArea: 1);
    expect(UtilSighting.shortSightingTour(prefTour: pref), isNull);

    final running = TourPref(date: '2026-11-05', tour_start: '19:37');
    final tour = UtilSighting.shortSightingTour(prefTour: pref, homeAreaTour: running)!;

    expect(UtilTourFid.createTTourFId(tour), '1-43-2026-11-05-19:37');
    expect(tour.beaufort_wind, '3');
  });
}
