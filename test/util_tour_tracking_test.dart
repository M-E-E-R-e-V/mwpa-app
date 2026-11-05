import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Util/UtilTourTracking.dart';

void main() {
  final now = DateTime(2026, 11, 5, 12);

  group('UtilTourTracking.canDeleteLocal', () {
    test('never deletes when the server has not confirmed all points', () {
      expect(UtilTourTracking.canDeleteLocal(
          isComplete: false, canDelete: true, latestDate: '2020-01-01 10:00:00', now: now), isFalse);
    });

    test('deletes confirmed tours when the server allows it', () {
      expect(UtilTourTracking.canDeleteLocal(
          isComplete: true, canDelete: true, latestDate: '2026-11-05 10:00:00', now: now), isTrue);
    });

    test('deletes confirmed tours older than the retention', () {
      expect(UtilTourTracking.canDeleteLocal(
          isComplete: true, canDelete: null, latestDate: '2026-10-05 11:59:59', now: now), isTrue);
    });

    test('keeps confirmed tours within the retention', () {
      expect(UtilTourTracking.canDeleteLocal(
          isComplete: true, canDelete: false, latestDate: '2026-10-07 08:00:00', now: now), isFalse);
    });

    test('keeps confirmed tours with missing or unparsable date', () {
      expect(UtilTourTracking.canDeleteLocal(isComplete: true, latestDate: null, now: now), isFalse);
      expect(UtilTourTracking.canDeleteLocal(isComplete: true, latestDate: 'garbage', now: now), isFalse);
    });
  });
}
