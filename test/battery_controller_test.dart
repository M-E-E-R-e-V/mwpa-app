import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Controllers/BatteryController.dart';
import 'package:mwpaapp/Util/UtilDevice.dart';

void main() {
  test('low = known level at or below 20 % and not charging', () {
    expect(BatteryController.isLowBattery(null), isFalse);
    expect(BatteryController.isLowBattery(const BatteryInfo(21, false)), isFalse);
    expect(BatteryController.isLowBattery(const BatteryInfo(20, false)), isTrue);
    expect(BatteryController.isLowBattery(const BatteryInfo(5, true)), isFalse);
  });

  test('refresh notifies only on a change', () async {
    var next = const BatteryInfo(50, false);
    final c = BatteryController(read: () async => next, autoStart: false);
    var notified = 0;
    c.addListener(() => notified++);

    await c.refresh();
    await c.refresh();
    expect(notified, 1);
    expect(c.isLow, isFalse);

    next = const BatteryInfo(15, false);
    await c.refresh();
    expect(notified, 2);
    expect(c.isLow, isTrue);

    next = const BatteryInfo(15, true);
    await c.refresh();
    expect(c.isLow, isFalse);
  });
}
