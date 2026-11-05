import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilImage.dart';
import 'package:path/path.dart' as p;

void main() {
  group('UtilDistanceCoast nm <-> meters', () {
    test('metersToNmText', () {
      expect(UtilDistanceCoast.metersToNmText('1852'), '1.0');
      expect(UtilDistanceCoast.metersToNmText('9327080.557932315'), '5036.22');
      expect(UtilDistanceCoast.metersToNmText(''), '');
      expect(UtilDistanceCoast.metersToNmText('abc'), '');
    });

    test('nmTextToMeters', () {
      expect(UtilDistanceCoast.nmTextToMeters('2.5'), '4630');
      expect(UtilDistanceCoast.nmTextToMeters('2,5'), '4630');
      expect(UtilDistanceCoast.nmTextToMeters(' '), '');
      expect(UtilDistanceCoast.nmTextToMeters('1.2.3'), isNull);
      expect(UtilDistanceCoast.nmTextToMeters('-1'), isNull);
    });

    test('round trip keeps 2 decimals', () {
      for (final nm in ['0.1', '2.53', '12.0', '0.0']) {
        final meters = UtilDistanceCoast.nmTextToMeters(nm)!;
        expect(double.parse(UtilDistanceCoast.metersToNmText(meters)), double.parse(nm), reason: nm);
      }
    });
  });

  group('UtilImage.persist', () {
    late Directory tmp;

    setUp(() => tmp = Directory.systemTemp.createTempSync('mwpa_img'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('copies a cache file into the image folder', () async {
      final src = File(p.join(tmp.path, 'cache', 'photo.jpg'))
        ..createSync(recursive: true)
        ..writeAsBytesSync([1, 2, 3]);

      final result = await UtilImage.persist(src.path, baseDir: tmp);

      expect(p.isWithin(p.join(tmp.path, UtilImage.dirName), result), isTrue);
      expect(result, endsWith('_photo.jpg'));
      expect(File(result).readAsBytesSync(), [1, 2, 3]);
    });

    test('keeps paths that are empty, missing or already persisted', () async {
      expect(await UtilImage.persist('', baseDir: tmp), '');

      final missing = p.join(tmp.path, 'gone.jpg');
      expect(await UtilImage.persist(missing, baseDir: tmp), missing);

      final kept = File(p.join(tmp.path, UtilImage.dirName, 'a.jpg'))
        ..createSync(recursive: true);
      expect(await UtilImage.persist(kept.path, baseDir: tmp), kept.path);
    });
  });
}
