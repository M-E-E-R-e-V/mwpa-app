import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// UtilImage - keeps sighting photos in app storage that Android does not
/// clear on its own (image_picker returns files in the cache directory).
class UtilImage {
  /// folder below the app documents directory
  static const String dirName = 'sighting_images';

  /// persist - copies the photo at [srcPath] into the sighting image folder
  /// below [baseDir] (default: app documents directory) and returns the new
  /// path. A path already inside the folder, an empty path or a missing file
  /// is returned unchanged, so it is safe to call on every save.
  static Future<String> persist(String srcPath, {Directory? baseDir}) async {
    if (srcPath.isEmpty) {
      return srcPath;
    }

    try {
      final base = baseDir ?? await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, dirName));

      if (p.isWithin(dir.path, srcPath) || !File(srcPath).existsSync()) {
        return srcPath;
      }

      await dir.create(recursive: true);

      final target = p.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(srcPath)}',
      );

      await File(srcPath).copy(target);
      return target;
    } catch (e) {
      AppLog.e('Image', 'persist: $srcPath', e);
    }

    // keep the original file rather than losing the photo
    return srcPath;
  }
}
