import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// BatteryInfo - battery level in percent and whether a charger is connected
@immutable
class BatteryInfo {
  final int level;
  final bool charging;

  const BatteryInfo(this.level, this.charging);
}

/// UtilDevice - small device functions over the own MethodChannel
/// `mwpa/device` (MainActivity.kt), no plugin needed. On other platforms
/// and in tests the calls do nothing / return null.
class UtilDevice {
  static const MethodChannel _channel = MethodChannel('mwpa/device');

  /// setKeepScreenOn - keeps the display on while the app is in front
  static Future<void> setKeepScreenOn(bool on) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _channel.invokeMethod('setKeepScreenOn', {'on': on});
    } catch (error) {
      AppLog.w('Device', 'keep screen on failed', error);
    }
  }

  /// battery - current battery state or null if unknown
  static Future<BatteryInfo?> battery() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('battery');

      if (map == null) {
        return null;
      }

      return BatteryInfo(map['level'] as int, map['charging'] as bool);
    } catch (error) {
      AppLog.w('Device', 'battery state failed', error);
      return null;
    }
  }
}
