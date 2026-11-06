import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';

void main() {
  final now = DateTime(2026, 11, 5, 12);

  test('no stream is off, even with an old fix', () {
    expect(
      LocationController.computeGpsStatus(running: false, lastFixAt: now, now: now),
      GpsStatus.off,
    );
  });

  test('stream without a fix is searching', () {
    expect(
      LocationController.computeGpsStatus(running: true, lastFixAt: null, now: now),
      GpsStatus.searching,
    );
  });

  test('a recent fix is ok, a stale one is searching', () {
    expect(
      LocationController.computeGpsStatus(
          running: true, lastFixAt: now.subtract(const Duration(seconds: 20)), now: now),
      GpsStatus.ok,
    );
    expect(
      LocationController.computeGpsStatus(
          running: true,
          lastFixAt: now.subtract(LocationController.fixStaleAfter + const Duration(seconds: 1)),
          now: now),
      GpsStatus.searching,
    );
  });
}
