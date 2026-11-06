import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// LogLevel - [debug] only goes to the console of debug builds, the other
/// levels are also written to the log file.
enum LogLevel {
  debug('D'),
  info('I'),
  warn('W'),
  error('E');

  final String short;

  const LogLevel(this.short);
}

/// AppLog - small own logger: writes info/warn/error lines to a log file in
/// the app storage (rotated at [maxFileBytes], one old file is kept), so
/// problems in the field can be shared from the About page.
///
/// Never log passwords, cookies or other credentials.
class AppLog {
  /// size of one log file before it is rotated
  static const int maxFileBytes = 512 * 1024;

  /// lines of a stack trace that are kept
  static const int maxStackLines = 12;

  /// lines kept in memory until [init] (or forever, if init failed)
  static const int _maxEarlyLines = 500;

  static const String _fileName = 'mwpa.log';
  static const String _oldFileName = 'mwpa.1.log';

  /// echo every entry to the console (debug builds; off in tests)
  static bool echoToConsole = kDebugMode;

  static Directory? _dir;

  /// lines logged before [init], written once the file is known
  static final List<String> _early = [];

  /// serializes the file writes, keeps the line order
  static Future<void> _pending = Future.value();

  /// init - opens the log directory ([dir] for tests, default
  /// `<app support>/logs`)
  static Future<void> init({Directory? dir}) async {
    try {
      final base = dir ?? Directory(p.join((await getApplicationSupportDirectory()).path, 'logs'));
      await base.create(recursive: true);
      _dir = base;

      if (_early.isNotEmpty) {
        final lines = List<String>.of(_early);
        _early.clear();
        _enqueue(lines.join());
      }
    } catch (error) {
      // logging must never break the app
      debugPrint('AppLog: init failed: $error');
    }
  }

  static void d(String tag, Object? message) => log(LogLevel.debug, tag, message);

  static void i(String tag, Object? message) => log(LogLevel.info, tag, message);

  static void w(String tag, Object? message, [Object? error, StackTrace? stack]) =>
      log(LogLevel.warn, tag, message, error, stack);

  static void e(String tag, Object? message, [Object? error, StackTrace? stack]) =>
      log(LogLevel.error, tag, message, error, stack);

  /// log - one entry; debug builds also print it to the console
  static void log(LogLevel level, String tag, Object? message, [Object? error, StackTrace? stack]) {
    final line = formatLine(DateTime.now(), level, tag, message, error, stack);

    if (echoToConsole) {
      debugPrint(line.trimRight());
    }

    if (level == LogLevel.debug) {
      return;
    }

    if (_dir == null) {
      // bounded: if init fails the app must not collect lines forever
      if (_early.length >= _maxEarlyLines) {
        _early.removeAt(0);
      }

      _early.add(line);
      return;
    }

    _enqueue(line);
  }

  /// formatLine - `2026-11-05 22:30:01.123 E Sync: message | error` plus the
  /// first stack lines, newline terminated
  @visibleForTesting
  static String formatLine(DateTime time, LogLevel level, String tag, Object? message,
      [Object? error, StackTrace? stack]) {
    final buffer = StringBuffer()
      ..write(_timestamp(time))
      ..write(' ')
      ..write(level.short)
      ..write(' ')
      ..write(tag)
      ..write(': ')
      ..write(message);

    if (error != null && error != message) {
      buffer
        ..write(' | ')
        ..write(error);
    }

    buffer.writeln();

    if (stack != null) {
      final lines = stack.toString().trimRight().split('\n');

      for (final l in lines.take(maxStackLines)) {
        buffer
          ..write('    ')
          ..writeln(l);
      }

      if (lines.length > maxStackLines) {
        buffer.writeln('    ...');
      }
    }

    return buffer.toString();
  }

  /// _timestamp - local time, millisecond precision
  static String _timestamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');

    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.'
        '${t.millisecond.toString().padLeft(3, '0')}';
  }

  static void _enqueue(String text) {
    _pending = _pending.then((_) => _write(text)).catchError((Object error) {
      debugPrint('AppLog: write failed: $error');
    });
  }

  static Future<void> _write(String text) async {
    final dir = _dir;

    if (dir == null) {
      return;
    }

    final file = File(p.join(dir.path, _fileName));

    if (await file.exists() && await file.length() >= maxFileBytes) {
      await file.rename(p.join(dir.path, _oldFileName));
    }

    await File(p.join(dir.path, _fileName)).writeAsString(text, mode: FileMode.append, flush: true);
  }

  /// flush - waits for the pending writes
  static Future<void> flush() => _pending;

  /// readAll - old and current log file, oldest first
  static Future<String> readAll() async {
    await flush();

    final dir = _dir;

    if (dir == null) {
      return _early.join();
    }

    final buffer = StringBuffer();

    for (final name in [_oldFileName, _fileName]) {
      final file = File(p.join(dir.path, name));

      if (await file.exists()) {
        buffer.write(await file.readAsString());
      }
    }

    return buffer.toString();
  }

  /// exportFile - both log files merged with a [header] into one file in
  /// [target] (default: temporary directory), for sharing
  static Future<File> exportFile({required String header, Directory? target}) async {
    final dir = target ?? await getTemporaryDirectory();

    // only the newest export is kept
    for (final old in dir.listSync().whereType<File>()) {
      if (p.basename(old.path).startsWith('mwpa-log-')) {
        await old.delete();
      }
    }
    final stamp = _timestamp(DateTime.now()).substring(0, 19).replaceAll(RegExp(r'[: ]'), '-');
    final file = File(p.join(dir.path, 'mwpa-log-$stamp.txt'));

    await file.writeAsString('$header\n\n${await readAll()}', flush: true);
    return file;
  }

  /// clear - deletes the log files
  static Future<void> clear() async {
    await flush();

    final dir = _dir;

    if (dir == null) {
      _early.clear();
      return;
    }

    for (final name in [_oldFileName, _fileName]) {
      final file = File(p.join(dir.path, name));

      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// resetForTest - forget the directory and the pending lines
  @visibleForTesting
  static void resetForTest() {
    _dir = null;
    _early.clear();
    _pending = Future.value();
  }
}
