import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';

Position _pos(double lat, double lon) => Position(
      latitude: lat, longitude: lon, timestamp: DateTime(2026, 11, 5),
      accuracy: 5, altitude: 0, altitudeAccuracy: 0, heading: 0,
      headingAccuracy: 0, speed: 0, speedAccuracy: 0);

void main() {
  group('UtilPosition', () {
    test('formats N/W without a minus sign', () {
      expect(UtilPosition.getStr(_pos(37.4219983, -122.084)),
          'N: 37° 25\' 19.194" - W: 122° 5\' 2.4" ');
    });

    test('formats S/E', () {
      expect(UtilPosition.formatDms(-33.8688, 151.2093),
          'S: 33° 52\' 7.68" - E: 151° 12\' 33.48" ');
    });

    test('seconds rounding carries into minutes and degrees', () {
      // 59.99999" rounds to 60" -> next minute; 59'59.9999" -> next degree
      expect(UtilPosition.toDms(10 + 59 / 60 + 59.99999 / 3600),
          (degrees: 11, minutes: 0, seconds: 0.0));
      expect(UtilPosition.toDms(28.5), (degrees: 28, minutes: 30, seconds: 0.0));
    });
  });

  group('UtilDistanceCoast.getDistance', () {
    test('a coast point itself has distance 0', () {
      final (lat, lon) = UtilDistanceCoast.coastPoints.first;
      expect(UtilDistanceCoast.getDistance(_pos(lat, lon)), 0);
    });

    test('takes the nearest of all coast points', () {
      final (lat, lon) = UtilDistanceCoast.coastPoints.last;
      final d = UtilDistanceCoast.getDistance(_pos(lat + 0.01, lon));

      // 0.01° latitude is about 1113 m - nearest point at most that far
      expect(d, greaterThan(0));
      expect(d, lessThanOrEqualTo(1114));
    });
  });
}
