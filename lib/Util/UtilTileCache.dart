import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// UtilTileCache - map tiles that were viewed once are kept for offline use.
///
/// flutter_map caches tiles by default in the app *cache* dir, which Android
/// may clear at any time (low storage, "clear cache") - possibly right before
/// a trip without network. The cache is therefore kept in app storage
/// (`<app support>/map_tiles`), limited to [maxCacheBytes]; the oldest tiles
/// are removed beyond that. The folder is excluded from Android backup
/// (res/xml/backup_rules.xml, data_extraction_rules.xml).
class UtilTileCache {
  /// sub folder of the app support dir
  static const String folder = 'map_tiles';

  /// flutter_map stores the tiles in this child of the given directory
  static const String cacheChild = 'fm_cache';

  /// upper limit of the tile cache (OSM tiles are ~10-50 KB each)
  static const int maxCacheBytes = 500 * 1000 * 1000;

  /// init - before the first map is shown (main); errors only disable the
  /// move, flutter_map then falls back to its default cache
  static Future<void> init() async {
    try {
      final base = Directory(p.join((await getApplicationSupportDirectory()).path, folder));

      await moveOldCache(
        from: Directory(p.join((await getApplicationCacheDirectory()).path, cacheChild)),
        to: Directory(p.join(base.path, cacheChild)),
      );

      BuiltInMapCachingProvider.getOrCreateInstance(
        cacheDirectory: base.path,
        maxCacheSize: maxCacheBytes,
      );
    } catch (e, s) {
      AppLog.w('TileCache', 'init failed, default cache used', e, s);
    }
  }

  /// moveOldCache - takes over the tiles of the old cache location once
  /// (same file system: a rename, no copy). Returns true if moved.
  static Future<bool> moveOldCache({required Directory from, required Directory to}) async {
    if (!await from.exists() || await to.exists()) {
      return false;
    }

    await to.parent.create(recursive: true);
    await from.rename(to.path);
    AppLog.i('TileCache', 'tile cache moved to app storage');

    return true;
  }
}
