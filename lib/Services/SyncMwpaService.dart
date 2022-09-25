import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Mwpa/MwpaAPI.dart';

class SyncMwpaService {

  Future<void> sync(Function(int)? update) async {
    MwpaApi api;

    // load userdata and login
    // -------------------------------------------------------------------------

    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(Preference.URL)) {
        throw Exception("Preference field 'URL' is not found!");
      }

      if (!prefs.containsKey(Preference.USERNAME)) {
        throw Exception("Preference field 'USERNAME' is not found!");
      }

      if (!prefs.containsKey(Preference.PASSWORD)) {
        throw Exception("Preference field 'PASSWORD' is not found!");
      }

      String url = prefs.getString(Preference.URL)!;
      String username = prefs.getString(Preference.USERNAME)!;
      String password = prefs.getString(Preference.PASSWORD)!;

      api = MwpaApi(url);

      if (!await api.isLogin()) {
        if (await api.login(username, password)) {
          if (!await api.isLogin()) {
            throw Exception("Login to MWPA failed by Username: '$username' !");
          }
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    // vehicle sync
    // -------------------------------------------------------------------------

    try {
      List<Vehicle> vehicleList = await api.getVehicleList();

      for (var vehicle in vehicleList) {
        var tVehicle = await DBHelper.readVehicle(vehicle.id!);

        if (tVehicle.isEmpty) {
          await DBHelper.insertVehicle(vehicle);
        } else {
          await DBHelper.updateVehicle(vehicle);
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }


    if (update != null) {
      await update(10);
    }

    // vehicle driver sync
    // -------------------------------------------------------------------------

    try {
      List<VehicleDriver> vehicleDriverList = await api.getVehicleDriverList();

      for (var vehicleDriver in vehicleDriverList) {
        var tVehicleDriver = await DBHelper.readVehicleDriver(vehicleDriver.id!);

        if (tVehicleDriver.isEmpty) {
          await DBHelper.insertVehicleDriver(vehicleDriver);
        } else {
          await DBHelper.updateVehicleDriver(vehicleDriver);
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    if (update != null) {
      await update(20);
    }

    // species
    // -------------------------------------------------------------------------

    try {
      List<Species> speciesList = await api.getSpeciesList();

      for (var species in speciesList) {
        var tspecie = await DBHelper.readSpecies(species.id!);

        if (tspecie.isEmpty) {
          await DBHelper.insertSpecies(species);
        } else {
          await DBHelper.updateSpecies(species);
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    if (update != null) {
      await update(30);
    }

    // encounter categories
    // -------------------------------------------------------------------------

    try {
      List<EncounterCategorie> encCatList = await api.getEncounterCategorieList();

      for (var encCat in encCatList) {
        var tEncCat = await DBHelper.readEncounterCategorie(encCat.id!);

        if (tEncCat.isEmpty) {
          await DBHelper.insertEncounterCategorie(encCat);
        } else {
          await DBHelper.updateEncounterCategorie(encCat);
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    if (update != null) {
      await update(40);
    }

    // behavioural state
    // -------------------------------------------------------------------------

    try {
      List<BehaviouralState> behStateList = await api.getBehaviouralStateList();

      for (var behState in behStateList) {
        var tBehState= await DBHelper.readBehaviouralState(behState.id!);

        if (tBehState.isEmpty) {
          await DBHelper.insertBehaviouralState(behState);
        } else {
          await DBHelper.updateBehaviouralState(behState);
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    // sightings
    // -------------------------------------------------------------------------

    List<Sighting> sightingList = [];
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList = sightings.map((data) => Sighting.fromJson(data)).toList();

    try {
      for (var sighting in sightingList) {
        if (await api.saveSighting(sighting)) {
          // delete sighting is send to portal
        }
      }
    } catch(e) {
      print(e);

      rethrow;
    }

    // -------------------------------------------------------------------------

    if (update != null) {
      await update(100);
    }
  }
}