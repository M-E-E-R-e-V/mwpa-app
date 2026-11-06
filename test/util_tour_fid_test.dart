import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';

void main() {
  group('UtilTourFid', () {
    test('createTTourFId builds vehicle-driver-date-start', () {
      final tour = TourPref(
        vehicle_id: 3,
        vehicle_driver_id: 7,
        date: '2026-06-08',
        tour_start: '09:15',
      );

      expect(UtilTourFid.createTTourFId(tour), '3-7-2026-06-08-09:15');
    });

    test('convertTourFid strips the time part of a full timestamp', () {
      expect(
        UtilTourFid.convertTourFid('3-7-2026-06-08 00:00:00.000Z-09:15'),
        '3-7-2026-06-08-09:15',
      );
    });

    test('convertTourFid keeps ids without a space unchanged', () {
      expect(UtilTourFid.convertTourFid('3-7-2026-06-08-09:15'), '3-7-2026-06-08-09:15');
    });
  });
}
