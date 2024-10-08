import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/TourTracking.dart';
import 'package:mwpaapp/Models/TrackingAreaHome.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:sqflite/sqflite.dart';

/// DBHelper
class DBHelper {
  static Database? _db;
  static const int _version = 11;
  static const String _tableNameSighting = "sighting";
  static const String _tableNameTourTracking = "tour_tracking";
  static const String _tableNameVehicle = "vehicle";
  static const String _tableNameVehicleDriver = "vehicle_driver";
  static const String _tableNameSpecies = "species";
  static const String _tableNameEncCate = "encounter_categories";
  static const String _tableNameBehState = "behavioural_state";
  static const String _tableNameTrackingAreaHome = 'tracking_area_home';

  /// initDb
  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }

    try {
      String path = '${await getDatabasesPath()}mwpa.db';
      _db = await openDatabase(
          path,
          version: _version,
          onUpgrade: (db, oldVersion, newVersion) async {
            var batch = db.batch();

            if (oldVersion <= 1) {
              _updateTableSightingV1toV2(batch);
            }

            if (oldVersion <= 2) {
              _updateTableSightingV2toV3(batch);
            }

            if (oldVersion <= 3) {
              _updateTableSightingV3toV4(batch);
            }

            if (oldVersion <= 4) {
              _updateTableSightingV4toV5(batch);
            }

            if (oldVersion <= 5) {
              _updateTableSightingV5toV6(batch);
            }

            if (oldVersion <= 6) {
              _updateTableSightingV6toV7(batch);
            }

            if (oldVersion <= 7 ) {
              _updateTableSightingV7toV8(batch);
            }

            if (oldVersion <= 8 ) {
              _updateTableSightingV8toV9(batch);
            }

            await batch.commit();
          },
          onCreate: (db, version) {
            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameSighting("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "unid STRING,"
                    "creater_id INTEGER,"
                    "vehicle_id INTEGER,"
                    "vehicle_driver_id INTEGER,"
                    "beaufort_wind STRING,"
                    "beaufort_wind_old INTEGER,"
                    "date STRING,"
                    "tour_fid,"
                    "tour_start STRING,"
                    "tour_end STRING,"
                    "duration_from STRING,"
                    "duration_until STRING,"
                    "location_begin STRING,"
                    "location_end STRING,"
                    "photo_taken INTEGER,"
                    "distance_coast STRING,"
                    "distance_coast_estimation_gps INTEGER,"
                    "species_id INTEGER,"
                    "species_count INTEGER,"
                    "juveniles INTEGER,"
                    "calves INTEGER,"
                    "newborns INTEGER,"
                    "behaviours STRING,"
                    "subgroups INTEGER,"
                    "reaction_id INTEGER,"
                    "freq_behaviour STRING,"
                    "recognizable_animals STRING,"
                    "group_structure_id INTEGER,"
                    "other_species STRING,"
                    "other STRING,"
                    "other_vehicle STRING,"
                    "note STRING,"
                    "image STRING,"
                    "syncStatus INTEGER,"
                    "sightingType INTEGER,"
                    "parentid INTEGER,"
                    "parentuid STRING"
                    ")"
            );

            db.execute(
              "CREATE TABLE IF NOT EXISTS $_tableNameTourTracking("
                  "uuid STRING PRIMARY KEY,"
                  "tour_fid STRING,"
                  "location STRING,"
                  "date STRING"
              ")"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameVehicle("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "name STRING,"
                    "isdeleted INTEGER)"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameVehicleDriver("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "user_id INTEGER, "
                    "description STRING, "
                    "username STRING, "
                    "isdeleted INTEGER)"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameSpecies("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "orgid INTEGER, "
                    "name STRING, "
                    "isdeleted INTEGER)"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameEncCate("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "name STRING,"
                    "isdeleted INTEGER)"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameBehState("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "name STRING, "
                    "description STRING, "
                    "isdeleted INTEGER)"
            );

            db.execute(
              "CREATE TABLE IF NOT EXISTS $_tableNameTrackingAreaHome("
                  "uuid STRING PRIMARY KEY, "
                  "orgid INTEGER, "
                  "cord_index INTEGER, "
                  "lon STRING, "
                  "lat STRING, "
                  "update_datetime INTEGER)"
            );

            return;
          }
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// _updateTableSightingV1toV2
  static void _updateTableSightingV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD group_structure_id INTEGER');
  }

  /// _updateTableSightingV2toV3
  static void _updateTableSightingV2toV3(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD syncStatus INTEGER');
  }

  /// _updateTableSightingV3toV4
  static void _updateTableSightingV3toV4(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting RENAME COLUMN beaufort_wind TO beaufort_wind_old');
    batch.execute('ALTER TABLE $_tableNameSighting ADD beaufort_wind STRING');
  }

  /// _updateTableSightingV4toV5
  static void _updateTableSightingV4toV5(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD creater_id INTEGER');
  }

  /// _updateTableSightingV5toV6
  static void _updateTableSightingV5toV6(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD sightingType INTEGER');
  }

  /// _updateTableSightingV6toV7
  static void _updateTableSightingV6toV7(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSpecies ADD orgid INTEGER');
  }

  /// _updateTableSightingV7toV8
  static void _updateTableSightingV7toV8(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD parentid INTEGER');
    batch.execute('ALTER TABLE $_tableNameSighting ADD parentuid STRING');
  }

  static void _updateTableSightingV8toV9(Batch batch) {
  }

  /// insertSighting
  static Future<int> insertSighting(Sighting newSighting) async {
    return await _db?.insert(_tableNameSighting, newSighting.toJson(false, true, false)) ?? 1;
  }

  /// querySighting
  static Future<List<Map<String, dynamic>>> querySighting() async {
    return await _db!.query(
        _tableNameSighting,
        orderBy: "id DESC"
    );
  }

  /// deleteSighting
  static Future<int> deleteSighting(Sighting oldSighting) async {
    return await _db!.delete(
        _tableNameSighting, where: 'id=?', whereArgs: [oldSighting.id]);
  }

  /// updateSighting
  static Future<int> updateSighting(Sighting uSighting) async {
    return await _db!.update(
        _tableNameSighting,
        uSighting.toJson(false, true, false),
        where: 'id=?',
        whereArgs: [uSighting.id]
    );
  }

  /// updateSightingEndTour
  static Future<int> updateSightingEndTour(String tourFid, String tourend) async {
    return await _db!.update(
      _tableNameSighting,
      {
        'tour_end': tourend
      },
      where: 'tour_fid=?',
      whereArgs: [tourFid]
    );
  }

  /// insertVehicle
  static Future<int> insertVehicle(Vehicle vehicle) async {
    return await _db?.insert(_tableNameVehicle, vehicle.toJson(false)) ?? 1;
  }

  /// queryVehicle
  static Future<List<Map<String, dynamic>>> queryVehicle(bool withDelete) async {
    if (withDelete) {
      return await _db!.query(_tableNameVehicle);
    } else {
      return await _db!.query(
        _tableNameVehicle,
        where: "isdeleted = ?",
        whereArgs: [0],
        orderBy: "name ASC"
      );
    }
  }

  /// readVehicle
  static Future<Map<String, dynamic>> readVehicle(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameVehicle,
        where: 'id = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// updateVehicle
  static Future<int> updateVehicle(Vehicle vehicle) async {
    return await _db!.update(
      _tableNameVehicle,
      vehicle.toJson(false),
      where: 'id = ?',
      whereArgs: [vehicle.id]
    );
  }

  /// insertVehicleDriver
  static Future<int> insertVehicleDriver(VehicleDriver driver) async {
    return await _db?.insert(_tableNameVehicleDriver, driver.toJson(false)) ?? 1;
  }

  /// queryVehicleDriver
  static Future<List<Map<String, dynamic>>> queryVehicleDriver(bool withDelete) async {
    if (withDelete) {
      return await _db!.query(_tableNameVehicleDriver);
    } else {
      return await _db!.query(
        _tableNameVehicleDriver,
        where: "isdeleted = ?",
        whereArgs: [0],
        orderBy: 'username ASC'
      );
    }
  }

  /// readVehicleDriver
  static Future<Map<String, dynamic>> readVehicleDriver(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameVehicleDriver,
        where: 'id = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// updateVehicleDriver
  static Future<int> updateVehicleDriver(VehicleDriver driver) async {
    return await _db!.update(
      _tableNameVehicleDriver,
      driver.toJson(false),
      where: 'id = ?',
      whereArgs: [driver.id]
    );
  }

  /// insertSpecies
  static Future<int> insertSpecies(Species species) async {
    return await _db?.insert(_tableNameSpecies, species.toDbJson(false)) ?? 1;
  }

  /// querySpecies
  static Future<List<Map<String, dynamic>>> querySpecies(bool withDelete) async {
    if (withDelete) {
      return await _db!.query(_tableNameSpecies);
    } else {
      return await _db!.query(
        _tableNameSpecies,
        where: "isdeleted = ?",
        whereArgs: [0],
        orderBy: 'name ASC'
      );
    }
  }

  /// readSpecies
  static Future<Map<String, dynamic>> readSpecies(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameSpecies,
        where: 'orgid = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// updateSpecies
  static Future<int> updateSpecies(Species species) async {
    return await _db!.update(
      _tableNameSpecies,
      species.toJson(false),
      where: 'orgid = ?',
      whereArgs: [species.id]
    );
  }

  /// truncateSpecies
  static Future<int> truncateSpecies() async {
    await _db!.delete(_tableNameSpecies);
    return await _db!.update('sqlite_sequence', {'seq':1}, where: 'name = ?', whereArgs: [_tableNameSpecies]);
  }

  /// insertEncounterCategorie
  static Future<int> insertEncounterCategorie(EncounterCategorie encCat) async {
    return await _db?.insert(_tableNameEncCate, encCat.toJson(false)) ?? 1;
  }

  /// queryEncounterCategorie
  static Future<List<Map<String, dynamic>>> queryEncounterCategorie(bool withDelete) async {
    if (withDelete) {
      return await _db!.query(_tableNameEncCate);
    } else {
      return await _db!.query(
        _tableNameEncCate,
        where: "isdeleted = ?",
        whereArgs: [0],
        orderBy: 'name ASC'
      );
    }
  }

  /// readEncounterCategorie
  static Future<Map<String, dynamic>> readEncounterCategorie(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameEncCate,
        where: 'id = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// updateEncounterCategorie
  static Future<int> updateEncounterCategorie(EncounterCategorie encCat) async {
    return await _db!.update(
      _tableNameEncCate,
      encCat.toJson(false),
      where: 'id = ?',
      whereArgs: [encCat.id]
    );
  }

  /// insertBehaviouralState
  static Future<int> insertBehaviouralState(BehaviouralState behState) async {
    return await _db?.insert(_tableNameBehState, behState.toJson(false)) ?? 1;
  }

  /// queryBehaviouralState
  static Future<List<Map<String, dynamic>>> queryBehaviouralState(bool withDelete) async {
    if (withDelete) {
      return await _db!.query(_tableNameBehState);
    } else {
      return await _db!.query(
        _tableNameBehState,
        where: "isdeleted = ?",
        whereArgs: [0],
        orderBy: 'name ASC'
      );
    }
  }

  /// readBehaviouralState
  static Future<Map<String, dynamic>> readBehaviouralState(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameBehState,
        where: 'id = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// updateBehaviouralState
  static Future<int> updateBehaviouralState(BehaviouralState behState) async {
    return await _db!.update(
      _tableNameBehState,
      behState.toJson(false),
      where: 'id = ?',
      whereArgs: [behState.id]
    );
  }

  /// insertTourTracking
  static Future<int> insertTourTracking(TourTracking behState) async {
    return await _db?.insert(_tableNameTourTracking, behState.toJson()) ?? 1;
  }

  /// readTourTracking
  static Future<Map<String, dynamic>> readTourTracking(String tourFId, String searchDate) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameTourTracking,
        where: "tour_fid = ? AND date LIKE ?",
        whereArgs: [tourFId, "$searchDate%"]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  /// queryTourTrackingFIds
  static Future<List<Map<String, dynamic>>> queryTourTrackingFIds() async {
    return await _db!.query(
        _tableNameTourTracking,
        columns: ['tour_fid'],
        groupBy: 'tour_fid',
        orderBy: "tour_fid DESC"
      );
  }

  /// queryTourTracking
  static Future<List<Map<String, dynamic>>> queryTourTracking(String tourFId, int offset, int limit) async {
    return await _db!.query(
      _tableNameTourTracking,
      where: "tour_fid = ?",
      whereArgs: [tourFId],
      limit: limit,
      offset: offset
    );
  }

  /// countTourTracking
  static Future<int> countTourTracking(String tourFId) async {
    return Sqflite.firstIntValue(await _db!.query(
        _tableNameTourTracking,
        columns: ['COUNT(*)'],
        where: "tour_fid = ?",
        whereArgs: [tourFId]
    )) ?? 0;
  }

  /// deleteTourTrackingEntries
  static Future<int> deleteTourTrackingEntries(String tourFId) async {
    return await _db!.delete(
        _tableNameTourTracking,
        where: "tour_fid = ?",
        whereArgs: [tourFId]
    );
  }

  /// tracking area home -------------------------------------------------------

  /// insert tracking area home
  static Future<int> insertTrackingAreaHome(TrackingAreaHome track) async {
    return await _db?.insert(_tableNameTrackingAreaHome, track.toJson()) ?? 1;
  }

  /// query tracking area home
  static Future<List<Map<String, dynamic>>> queryTrackingAreaHome(int orgId) async {
    return await _db!.query(
        _tableNameTrackingAreaHome,
        where: 'orgid = ?',
        whereArgs: [orgId]
    );
  }

  /// delete tracking area home
  static Future<int> deleteTrackingAreaHome(int orgId) async {
    return await _db!.delete(
        _tableNameTrackingAreaHome,
        where: "orgid = ?",
        whereArgs: [orgId]
    );
  }
}