import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilDate.dart';
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
      if (kDebugMode) {
        print(e);
      }

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
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }


    if (update != null) {
      await update(5);
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
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(10);
    }

    // species
    // -------------------------------------------------------------------------

    try {
      List<Species> speciesList = await api.getSpeciesList();

      for (var species in speciesList) {
        var tSpecie = await DBHelper.readSpecies(species.id!);

        if (tSpecie.isEmpty) {
          await DBHelper.insertSpecies(species);
        } else {
          await DBHelper.updateSpecies(species);
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(15);
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
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(20);
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
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(25);
    }

    // sightings
    // -------------------------------------------------------------------------

    List<Sighting> sightingList = [];
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList = sightings.map((data) => Sighting.fromJson(data)).toList();

    try {
      var index = 0;
      var count = sightingList.length;

      for (var sighting in sightingList) {
        index++;

        if (update != null) {
          var percentStep = 100*(index*2-1)/(count*2);
          var percentUpdate = 75*100/percentStep ?? (25+index);
          await update(percentUpdate.toInt());
        }


        String? unid = await api.saveSighting(sighting);

        if (unid != null) {
          sighting.unid = unid;
          await DBHelper.updateSighting(sighting);
        }

        if (update != null) {
          var percentStep2 = 100*(index*2)/(count*2);
          var percentUpdate2 = 75*100/percentStep2 ?? (25+index);
          await update(percentUpdate2.toInt());
        }

        if (sighting.image != null && sighting.image != "") {
          try {
            await api.saveSightingImage(sighting.unid!, sighting.image!);
          } catch(ei) {
            if (kDebugMode) {
              print(ei);
              // TODO later, handle upload is finish
            }
          }
        }

        if (UtilDate.isOverDays(DateTime.parse(sighting.date!).toLocal(), 7)) {
          // todo later for a update
          /*if (sighting.image != null && sighting.image != "") {
            File(sighting.image!).delete();
          }

          DBHelper.deleteSighting(sighting);*/
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }

      rethrow;
    }

    // -------------------------------------------------------------------------

    if (update != null) {
      await update(100);
    }
  }
}