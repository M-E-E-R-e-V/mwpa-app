import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// UtilNotificationPermission - Android 13+ runtime permission for
/// notifications (POST_NOTIFICATIONS). Without it the foreground
/// notification of the location tracking is not shown. Implemented in
/// android/app/src/main/kotlin/com/meer/mwpaapp/MainActivity.kt.
class UtilNotificationPermission {
  static const MethodChannel _channel = MethodChannel('mwpa/notification_permission');

  /// request - asks the user once (Android itself stops showing the dialog
  /// after the user declined twice); true when notifications are allowed.
  /// Never throws: tracking works without the notification.
  static Future<bool> request() async {
    if (kIsWeb || !Platform.isAndroid) {
      return true;
    }

    try {
      return await _channel.invokeMethod<bool>('request') ?? false;
    } catch (error) {
      if (kDebugMode) {
        print('UtilNotificationPermission: $error');
      }

      return false;
    }
  }
}
