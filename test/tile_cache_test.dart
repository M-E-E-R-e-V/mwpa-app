import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Util/UtilTileCache.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('tile_cache_test'));
  tearDown(() async => root.delete(recursive: true));

  test('old cache is moved to app storage with its tiles', () async {
    final from = Directory(p.join(root.path, 'cache', 'fm_cache'));
    final to = Directory(p.join(root.path, 'files', 'map_tiles', 'fm_cache'));
    await File(p.join(from.path, 'tile1')).create(recursive: true);

    expect(await UtilTileCache.moveOldCache(from: from, to: to), isTrue);
    expect(await File(p.join(to.path, 'tile1')).exists(), isTrue);
    expect(await from.exists(), isFalse);
  });

  test('nothing moved without old cache or when the new one exists', () async {
    final from = Directory(p.join(root.path, 'cache', 'fm_cache'));
    final to = Directory(p.join(root.path, 'files', 'map_tiles', 'fm_cache'));

    expect(await UtilTileCache.moveOldCache(from: from, to: to), isFalse);

    await File(p.join(from.path, 'old')).create(recursive: true);
    await File(p.join(to.path, 'new')).create(recursive: true);

    expect(await UtilTileCache.moveOldCache(from: from, to: to), isFalse);
    expect(await File(p.join(to.path, 'new')).exists(), isTrue);
    expect(await File(p.join(from.path, 'old')).exists(), isTrue);
  });
}
