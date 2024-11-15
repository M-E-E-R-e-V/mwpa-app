import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Models/TourTracking.dart';
import 'package:mwpaapp/Models/TrackingAreaHome.dart';
import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Mwpa/Models/Info.dart';
import 'package:mwpaapp/Mwpa/Models/SightingTourTrackingCheck.dart';
import 'package:mwpaapp/Mwpa/Models/TrackingAreaHomeData.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../Mwpa/Models/SightingSaveResponse.dart';
import '../Mwpa/MwpaAPI.dart';

/// SyncMwpaService
class SyncMwpaService {

  /// sync
  Future<void> sync(Function(int, String)? update) async {
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

      Info apiInfo = await api.getInfo();

      if (apiInfo.version_api_login != versionApiMobileLogin) {
        throw Exception("The API for login has changed, please update your app, the data will not be lost.");
      }

      if (apiInfo.version_api_sync != versionApiMobileSync) {
        throw Exception("The API for syncing has changed, please update your app, the data will not be lost.");
      }

      if (!await api.isLogin()) {
        if (await api.login(username, password)) {
          if (!await api.isLogin()) {
            throw Exception("Login to MWPA failed by Username: '$username' !");
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('SyncMwpaService::sync:login:');
        print(e);
      }

      rethrow;
    }

    // update user data
    // -------------------------------------------------------------------------

    try {
      final prefs = await SharedPreferences.getInstance();
      var userInfo = await api.getUserInfo();

      if (userInfo.user != null && userInfo.organization != null) {
        // update organization (user is switch)
        await prefs.setInt(Preference.ORGID, userInfo.organization!.id);
      }
    } catch(e) {
      if (kDebugMode) {
        print('SyncMwpaService::sync:userdata:');
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
        print('SyncMwpaService::sync:vehicle:');
        print(e);
      }

      rethrow;
    }


    if (update != null) {
      await update(5, 'vehicle driver sync');
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
        print('SyncMwpaService::sync:vehicleDriver:');
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(10, 'species sync');
    }

    // species
    // -------------------------------------------------------------------------

    try {
      List<Species> speciesList = await api.getSpeciesList();

      if (speciesList.isNotEmpty) {
        await DBHelper.truncateSpecies();

        for (var species in speciesList) {
          var tSpecie = await DBHelper.readSpecies(species.orgid!);

          if (tSpecie.isEmpty) {
            await DBHelper.insertSpecies(species);
          } else {
            await DBHelper.updateSpecies(species);
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('SyncMwpaService::sync:species:');
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(15, 'encounter categories sync');
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
        print('SyncMwpaService::sync:encounterCategorie:');
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(20, 'behavioural state sync');
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
        print('SyncMwpaService::sync:BehaviouralState:');
        print(e);
      }

      rethrow;
    }

    if (update != null) {
      await update(25, 'sightings sync');
    }

    /// home tracking area
    /// ------------------------------------------------------------------------

    try {
      TrackingAreaHomeData? trackingHomeData = await api.getHomeAreaTrackingArea();

      if (trackingHomeData != null) {
        bool isTrackingAreaHomeUpdate = true;

        /// clear old tracking area home data ----------------------------------
        List<Map<String, dynamic>> oldTrackingAreaHomeData = await DBHelper.queryTrackingAreaHome(
            trackingHomeData.organization_id
        );

        if (oldTrackingAreaHomeData.isNotEmpty) {
          TrackingAreaHome oldTrackingAreaHomeEntry = TrackingAreaHome.fromJson(
              oldTrackingAreaHomeData[0]
          );

          if (oldTrackingAreaHomeEntry.update_datetime != null) {
            if (trackingHomeData.update_datetime > oldTrackingAreaHomeEntry.update_datetime!) {
              await DBHelper.deleteTrackingAreaHome(trackingHomeData.organization_id);
            } else {
              isTrackingAreaHomeUpdate = false;
            }
          }
        }

        /// add new tracking area home data ------------------------------------
        if (isTrackingAreaHomeUpdate) {
          int trackingHomeCordIndex = 0;

          for (var cord in trackingHomeData.coordinates) {
            var uuid = const Uuid();

            await DBHelper.insertTrackingAreaHome(TrackingAreaHome(
                update_datetime: trackingHomeData.update_datetime,
                lat: '${cord.lat}',
                lon: '${cord.lon}',
                cord_index: trackingHomeCordIndex,
                orgid: trackingHomeData.organization_id,
                uuid: uuid.v4()
            ));

            trackingHomeCordIndex++;
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('SyncMwpaService::sync:TrackingAreaHomeData:');
        print(e);
      }

      rethrow;
    }

    /// sightings
    /// ------------------------------------------------------------------------

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
          var percentUpdate = (percentStep*75)/100;
          await update(percentUpdate.toInt(), 'sightings sync');
        }

        SightingSaveResponse? saveResponse;

        try {
          saveResponse = await api.saveSighting(sighting);

          if (saveResponse != null) {
            sighting.unid = saveResponse.unid;

            if (sighting.creater_id == null || sighting.creater_id == 0) {
              var pref = Preference();
              await pref.load();

              sighting.creater_id = pref.getUserId();
            }

            sighting.syncStatus = Sighting.SYNC_STATUS_FINISH;
            await DBHelper.updateSighting(sighting);
          }
        } catch(ei) {
          if (kDebugMode) {
            print('SyncMwpaService::sync:sightingUpdate: ');
            print(sighting.id);
          }

          rethrow;
        }

        if (update != null) {
          var percentStep2 = 100*(index*2)/(count*2);
          var percentUpdate2 = (percentStep2*75)/100;
          await update(percentUpdate2.toInt(), 'sightings image sync');
        }

        if (sighting.image != null && sighting.image != "") {
          try {
            if (!await api.existSightingImage(sighting.unid!, sighting.image!)) {
              await api.saveSightingImage(sighting.unid!, sighting.image!);
            }
          } catch(ei) {
            if (kDebugMode) {
              print('SyncMwpaService::sync:image: ');
              print(ei);
            }
          }
        }

        /// delete old sighting ------------------------------------------------

        if (saveResponse != null) {
          if (saveResponse.unid != null) {
            if (saveResponse.canDelete != null) {
              if (saveResponse.canDelete!) {
                if (sighting.image != null && sighting.image != "") {
                  if (kDebugMode) {
                    print('SyncMwpaService::sync:tracking: delete image from sighting: ${sighting.image}');
                  }

                  File(sighting.image!).delete();
                }

                if (kDebugMode) {
                  print('SyncMwpaService::sync:tracking: delete sighting: ${sighting.unid}');
                }

                DBHelper.deleteSighting(sighting);
              }
            } else {
              if (kDebugMode) {
                print('SyncMwpaService::sync:tracking: SightingSaveResponse canDelete is empty');
              }
            }
          } else {
            if (kDebugMode) {
              print('SyncMwpaService::sync:tracking: SightingSaveResponse unid is empty');
            }
          }
        } else {
          if (kDebugMode) {
            print('SyncMwpaService::sync:tracking: SightingSaveResponse is empty');
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('SyncMwpaService::sync:');
        print(e);
      }

      rethrow;
    }

    /// tracking
    /// ------------------------------------------------------------------------

    List<Map<String, dynamic>> tourFids = await DBHelper.queryTourTrackingFIds();

    for (var fidMap in tourFids) {
      var tourFId = UtilTourFid.convertTourFid(fidMap['tour_fid']);

      try {
        var trackingCount = await DBHelper.countTourTracking(tourFId);
        var checkResponse = await api.checkSightingTourTracking(
            SightingTourTrackingCheck(tour_fid: tourFId, count: trackingCount)
        );

        if (checkResponse != null) {
          var isComplete = checkResponse.isComplete ?? false;

          if (! isComplete) {
            var limitSteps = 100;
            var offset = 0;

            while (offset<trackingCount) {
              if (update != null) {
                await update(90, 'sightings tracking sync $offset/$trackingCount');
              }

              List<Map<String, dynamic>> tracks = await DBHelper.queryTourTracking(tourFId, offset, limitSteps);
              List<TourTracking> trackList = tracks.map((data) => TourTracking.fromJson(data)).toList();

              await api.saveSightingTourTracking(trackList);

              offset += limitSteps;
            }
          } else {
            if (kDebugMode) {
              print('SyncMwpaService::sync:tracking: SightingTourTrackingCheck isComplete: $isComplete');
            }

            if (checkResponse.canDelete != null) {
              var canDelete = checkResponse.canDelete ?? false;

              if (canDelete) {
                if (kDebugMode) {
                  print('SyncMwpaService::sync:tracking: delete tracking entries by tourFId: $tourFId');
                }

                await DBHelper.deleteTourTrackingEntries(tourFId);
              }
            }
            else {
              if (kDebugMode) {
                print('SyncMwpaService::sync:tracking: checkSightingTourTracking canDelete is empty');
              }
            }
          }
        } else {
          if (kDebugMode) {
            print('SyncMwpaService::sync:tracking: SightingTourTrackingCheck return null');
          }
        }
      } catch(e) {
        if (kDebugMode) {
          print('SyncMwpaService::sync:tracking:');
          print(e);
        }

        rethrow;
      }
    }

    /// ------------------------------------------------------------------------

    if (update != null) {
      await update(100, 'finish');
    }
  }
}