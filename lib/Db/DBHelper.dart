import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableNameSighting = "sighting";
  static final String _tableNameVehicle = "vehicle";
  static final String _tableNameVehicleDriver = "vehicle_driver";
  static final String _tableNameSpecies = "species";

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }

    try {
      String path = '${await getDatabasesPath()}mwpa.db';
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) {
          db.execute(
            "CREATE TABLE IF NOT EXISTS $_tableNameSighting("
              "id INTEGER PRIMARY KEY AUTOINCREMENT,"
              "unid STRING,"
              "vehicle_id INTEGER,"
              "vehicle_driver_id INTEGER,"
              "date STRING,"
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
              "note STRING"
              ")"
          );

          db.execute(
            "CREATE TABLE IF NOT EXISTS $_tableNameVehicle("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "name STRING)"
          );

          db.execute(
            "CREATE TABLE IF NOT EXISTS $_tableNameVehicleDriver("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "user_id INTEGER,"
              "description STRING,"
              "username STRING)"
          );

          db.execute(
            "CREATE TABLE IF NOT EXISTS $_tableNameSpecies("
                "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                "name STRING)"
          );

          return;
        }
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<int> insertSighting(Sighting newSighting) async {
    return await _db?.insert(_tableNameSighting, newSighting.toJson())??1;
  }

  static Future<List<Map<String, dynamic>>> querySighting() async {
    return await _db!.query(
      _tableNameSighting,
      orderBy: "date DESC"
    );
  }

  static Future<int> deleteSighting(Sighting oldSighting) async {
    return await _db!.delete(_tableNameSighting, where: 'id=?', whereArgs: [oldSighting.id]);
  }

  static Future<int> updateSighting(Sighting uSighting) async {
    return await _db!.update(
        _tableNameSighting,
        uSighting.toJson()
    );
  }

  static Future<int> insertVehicle(Vehicle vehicle) async {
    return await _db?.insert(_tableNameVehicle, vehicle.toJson())??1;
  }

  static Future<List<Map<String, dynamic>>> queryVehicle() async {
    return await _db!.query(_tableNameVehicle);
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
        vehicle.toJson()
    );
  }

  static Future<int> insertVehicleDriver(VehicleDriver driver) async {
    return await _db?.insert(_tableNameVehicleDriver, driver.toJson())??1;
  }

  static Future<List<Map<String, dynamic>>> queryVehicleDriver() async {
    return await _db!.query(_tableNameVehicleDriver);
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
        driver.toJson()
    );
  }

  static Future<int> insertSpecies(Species species) async {
    return await _db?.insert(_tableNameSpecies, species.toJson())??1;
  }

  static Future<List<Map<String, dynamic>>> querySpecies() async {
    return await _db!.query(_tableNameSpecies);
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
        species.toJson()
    );
  }
}