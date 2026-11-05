import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Util/UtilDate.dart';

void main() {
  group('UtilDate', () {
    test('differenceInCalendarDays ignores the time of day', () {
      expect(
        UtilDate.differenceInCalendarDays(
          DateTime(2026, 6, 9, 0, 5),
          DateTime(2026, 6, 8, 23, 55),
        ),
        1,
      );
    });

    test('isCurrentDate', () {
      expect(UtilDate.isCurrentDate(DateTime.now()), isTrue);
      expect(
        UtilDate.isCurrentDate(DateTime.now().subtract(const Duration(days: 1))),
        isFalse,
      );
    });
  });
}
