import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Constants.dart';

void main() {
  test('kAppVersion/kAppBuild match the version in pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));

    expect(line.substring('version:'.length).trim(), '$kAppVersion+$kAppBuild',
        reason: 'update kAppVersion/kAppBuild in lib/Constants.dart');
  });
}
