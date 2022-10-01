import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/TourTracking.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 2;
  static const String _tableNameSighting = "sighting";
  static const String _tableNameTourTracking = "tour_tracking";
  static const String _tableNameVehicle = "vehicle";
  static const String _tableNameVehicleDriver = "vehicle_driver";
  static const String _tableNameSpecies = "species";
  static const String _tableNameEncCate = "encounter_categories";
  static const String _tableNameBehState = "behavioural_state";

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

            if (oldVersion == 1) {
              _updateTableSightingV1toV2(batch);
            }

            await batch.commit();
          },
          onCreate: (db, version) {
            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameSighting("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                    "unid STRING,"
                    "vehicle_id INTEGER,"
                    "vehicle_driver_id INTEGER,"
                    "beaufort_wind INTEGER,"
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
                    "other_species STRING,"
                    "other STRING,"
                    "other_vehicle STRING,"
                    "note STRING,"
                    "image STRING"
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
                    "user_id INTEGER,"
                    "description STRING,"
                    "username STRING,"
                    "isdeleted INTEGER)"
            );

            db.execute(
                "CREATE TABLE IF NOT EXISTS $_tableNameSpecies("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "name STRING,"
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
                    "name STRING,"
                    "description STRING,"
                    "isdeleted INTEGER)"
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

  static void _updateTableSightingV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $_tableNameSighting ADD group_structure_id INTEGER');
  }

  static Future<int> insertSighting(Sighting newSighting) async {
    return await _db?.insert(_tableNameSighting, newSighting.toJson(false)) ?? 1;
  }

  static Future<List<Map<String, dynamic>>> querySighting() async {
    return await _db!.query(
        _tableNameSighting,
        orderBy: "id DESC"
    );
  }

  static Future<int> deleteSighting(Sighting oldSighting) async {
    return await _db!.delete(
        _tableNameSighting, where: 'id=?', whereArgs: [oldSighting.id]);
  }

  static Future<int> updateSighting(Sighting uSighting) async {
    return await _db!.update(
        _tableNameSighting,
        uSighting.toJson(false),
        where: 'id=?',
        whereArgs: [uSighting.id]
    );
  }

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

  static Future<int> insertVehicle(Vehicle vehicle) async {
    return await _db?.insert(_tableNameVehicle, vehicle.toJson(false)) ?? 1;
  }

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

  static Future<int> updateVehicle(Vehicle vehicle) async {
    return await _db!.update(
      _tableNameVehicle,
      vehicle.toJson(false),
      where: 'id = ?',
      whereArgs: [vehicle.id]
    );
  }

  static Future<int> insertVehicleDriver(VehicleDriver driver) async {
    return await _db?.insert(_tableNameVehicleDriver, driver.toJson(false)) ?? 1;
  }

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

  static Future<int> updateVehicleDriver(VehicleDriver driver) async {
    return await _db!.update(
      _tableNameVehicleDriver,
      driver.toJson(false),
      where: 'id = ?',
      whereArgs: [driver.id]
    );
  }

  static Future<int> insertSpecies(Species species) async {
    return await _db?.insert(_tableNameSpecies, species.toJson(false)) ?? 1;
  }

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

  static Future<Map<String, dynamic>> readSpecies(int id) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameSpecies,
        where: 'id = ?',
        whereArgs: [id]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }

  static Future<int> updateSpecies(Species species) async {
    return await _db!.update(
      _tableNameSpecies,
      species.toJson(false),
      where: 'id = ?',
      whereArgs: [species.id]
    );
  }

  static Future<int> insertEncounterCategorie(EncounterCategorie encCat) async {
    return await _db?.insert(_tableNameEncCate, encCat.toJson(false)) ?? 1;
  }

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

  static Future<int> updateEncounterCategorie(EncounterCategorie encCat) async {
    return await _db!.update(
      _tableNameEncCate,
      encCat.toJson(false),
      where: 'id = ?',
      whereArgs: [encCat.id]
    );
  }

  static Future<int> insertBehaviouralState(BehaviouralState behState) async {
    return await _db?.insert(_tableNameBehState, behState.toJson(false)) ?? 1;
  }

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

  static Future<int> updateBehaviouralState(BehaviouralState behState) async {
    return await _db!.update(
      _tableNameBehState,
      behState.toJson(false),
      where: 'id = ?',
      whereArgs: [behState.id]
    );
  }

  static Future<int> insertTourTracking(TourTracking behState) async {
    return await _db?.insert(_tableNameTourTracking, behState.toJson()) ?? 1;
  }

  static Future<Map<String, dynamic>> readTourTracking(String tourFId, String searchDate) async {
    List<Map<String, dynamic>> list = await _db!.query(
        _tableNameTourTracking,
        where: "tour_fid = ? AND date LIKE ?",
        whereArgs: [tourFId, "${searchDate}%"]
    );

    if (list.isNotEmpty) {
      return list[0];
    }

    return {};
  }
}