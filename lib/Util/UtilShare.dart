import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// UtilShare - opens the system share sheet for a file (Android, own
/// MethodChannel "mwpa/share" in MainActivity.kt with a FileProvider; the
/// file must be in the cache directory).
class UtilShare {
  static const MethodChannel _channel = MethodChannel('mwpa/share');

  /// shareFile - false when sharing is not available on this platform
  static Future<bool> shareFile(String path, {String mimeType = 'text/plain', String subject = ''}) async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await _channel.invokeMethod<bool>('shareFile', {
      'path': path,
      'mimeType': mimeType,
      'subject': subject,
    }) ?? false;
  }
}
