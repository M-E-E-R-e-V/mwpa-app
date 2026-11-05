import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Util/AppLog.dart';

void main() {
  late Directory dir;

  setUp(() async {
    AppLog.resetForTest();
    AppLog.echoToConsole = false;
    dir = await Directory.systemTemp.createTemp('applog');
  });

  tearDown(() async {
    await AppLog.flush();
    await dir.delete(recursive: true);
  });

  test('formatLine with error and shortened stack', () {
    final stack = StackTrace.fromString(List.generate(20, (i) => '#$i frame').join('\n'));
    final line = AppLog.formatLine(
      DateTime(2026, 11, 5, 22, 30, 1, 123), LogLevel.error, 'Sync', 'login failed',
      Exception('boom'), stack,
    );

    expect(line, startsWith('2026-11-05 22:30:01.123 E Sync: login failed | Exception: boom\n'));
    expect(line, contains('    #11 frame\n'));
    expect(line, isNot(contains('#12 frame')));
    expect(line, endsWith('    ...\n'));
  });

  test('lines before init are kept, debug is not written', () async {
    AppLog.i('Test', 'early');
    await AppLog.init(dir: dir);
    AppLog.d('Test', 'debug only');
    AppLog.w('Test', 'later');

    final text = await AppLog.readAll();
    expect(text, contains('I Test: early'));
    expect(text, contains('W Test: later'));
    expect(text, isNot(contains('debug only')));
    expect(text.indexOf('early'), lessThan(text.indexOf('later')));
  });

  test('rotates at maxFileBytes and keeps one old file', () async {
    await AppLog.init(dir: dir);
    final payload = 'x' * 10000;

    for (var i = 0; i < 120; i++) {
      AppLog.i('Test', '$i $payload');
    }

    await AppLog.flush();

    final files = dir.listSync().map((f) => f.uri.pathSegments.last).toSet();
    expect(files, {'mwpa.log', 'mwpa.1.log'});

    for (final f in dir.listSync().whereType<File>()) {
      expect(f.lengthSync(), lessThan(AppLog.maxFileBytes + 11000));
    }

    final text = await AppLog.readAll();
    expect(text, contains('I Test: 119 '));
  });

  test('exportFile merges header and log, clear deletes', () async {
    await AppLog.init(dir: dir);
    AppLog.e('Api', 'timeout');

    final out = await Directory.systemTemp.createTemp('applog_out');
    await File('${out.path}/mwpa-log-old.txt').writeAsString('old');
    final file = await AppLog.exportFile(header: 'MWPA 1.1.0', target: out);
    final text = await file.readAsString();

    expect(file.path, contains('mwpa-log-'));
    expect(text, startsWith('MWPA 1.1.0\n\n'));
    expect(text, contains('E Api: timeout'));
    expect(out.listSync().length, 1, reason: 'older exports are removed');

    await AppLog.clear();
    expect(await AppLog.readAll(), isEmpty);
    await out.delete(recursive: true);
  });
}
