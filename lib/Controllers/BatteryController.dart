import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/Util/UtilDevice.dart';

/// BatteryController - polls the battery state; [isLow] drives the warning
/// banner on the main screen (GPS tracking drains the battery on long tours).
class BatteryController extends ChangeNotifier {
  /// at or below this level (percent, not charging) the app warns
  static const int lowLevel = 20;

  static const Duration pollInterval = Duration(minutes: 1);

  final Future<BatteryInfo?> Function() _read;
  Timer? _timer;
  BatteryInfo? _info;

  BatteryController({Future<BatteryInfo?> Function()? read, bool autoStart = true})
      : _read = read ?? UtilDevice.battery {
    if (autoStart) {
      refresh();
      _timer = Timer.periodic(pollInterval, (_) => refresh());
    }
  }

  BatteryInfo? get info => _info;

  /// isLow - level known, at or below [lowLevel] and not charging
  bool get isLow => isLowBattery(_info);

  @visibleForTesting
  static bool isLowBattery(BatteryInfo? info) =>
      info != null && !info.charging && info.level <= lowLevel;

  /// refresh - reads the state now
  Future<void> refresh() async {
    final info = await _read();
    final wasLow = isLow;
    final changed = info?.level != _info?.level || info?.charging != _info?.charging;
    _info = info;

    if (isLow != wasLow) {
      AppLog.i('Battery', isLow ? 'low: ${info!.level} %' : 'ok again');
    }

    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
