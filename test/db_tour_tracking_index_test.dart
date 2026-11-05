import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/TourTracking.dart';
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
}
