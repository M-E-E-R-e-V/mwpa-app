import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/TourTracking.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Path DBHelper.initDb uses (note: no separator, kept for compatibility).
Future<String> _dbPath() async => '${await getDatabasesPath()}mwpa.db';

Future<List<String>> _indexNames(String path) async {
  final db = await openDatabase(path, readOnly: true, singleInstance: false);
  final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'tour_tracking'");
  final plan = await db.rawQuery(
      "EXPLAIN QUERY PLAN SELECT * FROM tour_tracking "
      "WHERE tour_fid = ? AND date >= ? AND date < ? ORDER BY date LIMIT 1",
      ['t', '2026-06-08 10:05', '2026-06-08 10:05￿']);
  await db.close();

  return [
    ...rows.map((r) => r['name'] as String),
    ...plan.map((r) => 'plan: ${r['detail']}'),
  ];
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DBHelper.closeDb();
    final file = File(await _dbPath());
    if (file.existsSync()) file.deleteSync();
  });

  tearDownAll(() => DBHelper.closeDb());

  test('fresh install creates the tour_tracking (tour_fid, date) index', () async {
    await DBHelper.initDb();

    final names = await _indexNames(await _dbPath());
    expect(names, contains('idx_tour_tracking_tour_date'));
    expect(names.any((n) => n.contains('USING INDEX idx_tour_tracking_tour_date')), isTrue);
  });

  test('upgrade from v11 adds the index and keeps existing rows', () async {
    final path = await _dbPath();
    final old = await openDatabase(path, version: 11, onCreate: (db, _) async {
      await db.execute('CREATE TABLE sighting(id INTEGER PRIMARY KEY AUTOINCREMENT)');
      await db.execute('CREATE TABLE tour_tracking('
          'uuid STRING PRIMARY KEY, tour_fid STRING, location STRING, date STRING)');
      await db.insert('tour_tracking', {
        'uuid': 'u1', 'tour_fid': 'tour-a', 'location': '{}', 'date': '2026-06-08 10:05:30',
      });
    });
    await old.close();

    await DBHelper.initDb();

    expect(await _indexNames(path), contains('idx_tour_tracking_tour_date'));
    expect(await DBHelper.countTourTracking('tour-a'), 1);
  });

  test('readTourTracking finds the entry by minute prefix only within the tour', () async {
    await DBHelper.initDb();

    Future<void> add(String uuid, String tour, String date) =>
        DBHelper.insertTourTracking(
            TourTracking(uuid: uuid, tour_fid: tour, location: '{"n":"$uuid"}', date: date));

    await add('a1', 'tour-a', '2026-06-08 10:04:50');
    await add('a2', 'tour-a', '2026-06-08 10:05:10');
    await add('a3', 'tour-a', '2026-06-08 10:05:40');
    await add('a4', 'tour-a', '2026-06-08 10:06:00');
    await add('b1', 'tour-b', '2026-06-08 10:05:00');

    final hit = await DBHelper.readTourTracking('tour-a', '2026-06-08 10:05');
    expect(hit['uuid'], 'a2');

    expect(await DBHelper.readTourTracking('tour-a', '2026-06-08 10:07'), isEmpty);
    expect((await DBHelper.readTourTracking('tour-b', '2026-06-08 10:05'))['uuid'], 'b1');
  });

  test('latestTourTrackingDate returns the newest point of the tour', () async {
    await DBHelper.initDb();

    expect(await DBHelper.latestTourTrackingDate('tour-a'), isNull);

    for (final (uuid, tour, date) in [
      ('a1', 'tour-a', '2026-06-08 10:04:50'),
      ('a2', 'tour-a', '2026-06-08 16:30:00'),
      ('b1', 'tour-b', '2026-06-09 09:00:00'),
    ]) {
      await DBHelper.insertTourTracking(
          TourTracking(uuid: uuid, tour_fid: tour, location: '{}', date: date));
    }

    expect(await DBHelper.latestTourTrackingDate('tour-a'), '2026-06-08 16:30:00');
  });

  group('tracking upload (synced flag, DB v13)', () {
    Future<void> addPoints(String tour, int count, {int from = 0}) async {
      for (var i = from; i < from + count; i++) {
        final minute = '${i ~/ 60}'.padLeft(2, '0');
        final second = '${i % 60}'.padLeft(2, '0');
        await DBHelper.insertTourTracking(TourTracking(
            uuid: '$tour-$i', tour_fid: tour, location: '{}', date: '2026-06-08 10:$minute:$second'));
      }
    }

    test('upgrade from v12 adds the synced column, existing points unsynced', () async {
      final path = await _dbPath();
      final old = await openDatabase(path, version: 12, onCreate: (db, _) async {
        await db.execute('CREATE TABLE sighting(id INTEGER PRIMARY KEY AUTOINCREMENT)');
        await db.execute('CREATE TABLE tour_tracking('
            'uuid STRING PRIMARY KEY, tour_fid STRING, location STRING, date STRING)');
        await db.insert('tour_tracking', {
          'uuid': 'u1', 'tour_fid': 'tour-a', 'location': '{}', 'date': '2026-06-08 10:05:30',
        });
      });
      await old.close();

      await DBHelper.initDb();

      expect(await DBHelper.countUnsyncedTourTracking('tour-a'), 1);
      expect(await DBHelper.markTourTrackingSynced(['u1']), 1);
      expect(await DBHelper.countUnsyncedTourTracking('tour-a'), 0);
    });

    test('sends only new points of a growing tour', () async {
      await DBHelper.initDb();
      final sent = <List<String>>[];
      Future<bool> save(List<TourTracking> t) async {
        sent.add(t.map((e) => e.uuid!).toList());
        return true;
      }

      await addPoints('tour-a', 250);
      expect(await SyncMwpaService.uploadTourTracking('tour-a', save), 250);
      expect(sent.map((b) => b.length), [100, 100, 50]);
      expect(sent.first.first, 'tour-a-0', reason: 'oldest points first');

      // the tour keeps recording: the next sync only sends the new points
      sent.clear();
      await addPoints('tour-a', 30, from: 250);
      expect(await SyncMwpaService.uploadTourTracking('tour-a', save), 30);
      expect(sent.single.first, 'tour-a-250');
    });

    test('a rejected batch stays unsynced and is sent with the next sync', () async {
      await DBHelper.initDb();
      await addPoints('tour-a', 150);

      var calls = 0;
      final sent = await SyncMwpaService.uploadTourTracking('tour-a', (_) async => ++calls == 1);

      expect(sent, 100);
      expect(calls, 2, reason: 'stops after the rejected batch');
      expect(await DBHelper.countUnsyncedTourTracking('tour-a'), 50);

      expect(await SyncMwpaService.uploadTourTracking('tour-a', (_) async => true), 50);
      expect(await DBHelper.countUnsyncedTourTracking('tour-a'), 0);
    });

    test('server incomplete although all points are flagged: full upload', () async {
      await DBHelper.initDb();
      await addPoints('tour-a', 120);
      await addPoints('tour-b', 5);
      await DBHelper.setTourTrackingSynced('tour-a', true);

      expect(await SyncMwpaService.uploadTourTracking('tour-a', (_) async => true), 120);
      expect(await DBHelper.countUnsyncedTourTracking('tour-b'), 5, reason: 'other tours untouched');
    });
  });
}
