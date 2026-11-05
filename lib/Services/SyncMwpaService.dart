import 'dart:io';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
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
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:mwpaapp/Util/UtilTourTracking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../Mwpa/Models/SightingSaveResponse.dart';
import '../Mwpa/MwpaAPI.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// SyncStep - the phase a running sync reports; the UI shows it in the
/// user's language (the service itself has no BuildContext)
enum SyncStep {
  vehicles,
  species,
  encounterCategories,
  behaviouralStates,
  sightings,
  sightingImages,
  tracking,
  finish,
}

/// SyncUpdate - progress callback: [percent] 0..100, the current [step] and
/// an optional [detail] (e.g. "120/450" while uploading tracking points)
typedef SyncUpdate = Future<void> Function(int percent, SyncStep step, [String? detail]);

/// ApiVersionException - the server's mobile API version is not accepted
/// by this app build ([sync] false = login API, true = sync API)
class ApiVersionException implements Exception {
  final bool sync;
  final String server;
  final List<String> accepted;

  const ApiVersionException({required this.sync, required this.server, required this.accepted});

  @override
  String toString() =>
      "The API for ${sync ? 'syncing' : 'login'} has changed (server reports '$server', "
      "app accepts ${accepted.join(', ')}). Please update your app, the data will not be lost.";
}

/// SyncMwpaService
class SyncMwpaService {

  /// points per upload request
  static const int trackingBatchSize = 100;

  /// uploadTourTracking - uploads the tracking points of [tourFId] that were
  /// not sent yet (synced = 0) in batches through [save] and flags each
  /// uploaded batch; returns the number of points sent.
  ///
  /// Called when the server reports the tour as incomplete. If every local
  /// point is already flagged, the server lost points we sent before (e.g.
  /// restored database) - then the whole tour is sent again; the server
  /// skips points it already has (by uuid).
  ///
  /// A batch the server does not accept stays unflagged and the upload stops;
  /// it is retried with the next sync.
  static Future<int> uploadTourTracking(
    String tourFId,
    Future<bool> Function(List<TourTracking> tracks) save, {
    Future<void> Function(int sent, int total)? progress,
  }) async {
    if (await DBHelper.countUnsyncedTourTracking(tourFId) == 0) {
      await DBHelper.setTourTrackingSynced(tourFId, false);
    }

    final total = await DBHelper.countUnsyncedTourTracking(tourFId);
    var sent = 0;

    while (sent < total) {
      await progress?.call(sent, total);

      final rows = await DBHelper.queryUnsyncedTourTracking(tourFId, trackingBatchSize);

      if (rows.isEmpty) {
        break;
      }

      final tracks = rows.map((data) => TourTracking.fromJson(data)).toList();

      if (!await save(tracks)) {
        AppLog.i('Sync', 'uploadTourTracking: batch not accepted for $tourFId, retry with next sync');

        break;
      }

      await DBHelper.markTourTrackingSynced(rows.map((r) => r['uuid'] as String).toList());
      sent += rows.length;
    }

    return sent;
  }


  /// species lookup for translating local species ids (other_species)
  final SpeciesController speciesController;

  SyncMwpaService(this.speciesController);

  /// sync
  Future<void> sync(SyncUpdate? update) async {
    MwpaApi? opened;
    final watch = Stopwatch()..start();
    AppLog.i('Sync', 'start');

    try {
      await _sync(update, (api) => opened = api);
      AppLog.i('Sync', 'finished in ${watch.elapsedMilliseconds} ms');
    } catch (error) {
      AppLog.e('Sync', 'aborted after ${watch.elapsedMilliseconds} ms', error);
      rethrow;
    } finally {
      // release the kept-alive connection to the server
      opened?.close();
    }
  }

  /// _sync - the sync steps; [onApi] receives the API client once created
  Future<void> _sync(SyncUpdate? update, void Function(MwpaApi api) onApi) async {
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

      final password = await CredentialStore().readPassword();

      if (password == null) {
        throw Exception("No password stored, please sign in again!");
      }

      String url = prefs.getString(Preference.URL)!;
      String username = prefs.getString(Preference.USERNAME)!;

      api = MwpaApi(url);
      onApi(api);

      Info apiInfo = await api.getInfo();

      if (!versionApiMobileLogin.contains(apiInfo.version_api_login)) {
        throw ApiVersionException(
            sync: false, server: '${apiInfo.version_api_login}', accepted: versionApiMobileLogin.toList());
      }

      if (!versionApiMobileSync.contains(apiInfo.version_api_sync)) {
        throw ApiVersionException(
            sync: true, server: '${apiInfo.version_api_sync}', accepted: versionApiMobileSync.toList());
      }

      if (!await api.isLogin()) {
        if (await api.login(username, password)) {
          if (!await api.isLogin()) {
            throw Exception("Login to MWPA failed by Username: '$username' !");
          }
        }
      }
    } catch(e) {
      AppLog.e('Sync', 'login failed', e);

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
      AppLog.e('Sync', 'userdata failed', e);

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
      AppLog.e('Sync', 'vehicle failed', e);

      rethrow;
    }


    if (update != null) {
      await update(5, SyncStep.vehicles);
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
      AppLog.e('Sync', 'vehicleDriver failed', e);

      rethrow;
    }

    if (update != null) {
      await update(10, SyncStep.species);
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
      AppLog.e('Sync', 'species failed', e);

      rethrow;
    }

    if (update != null) {
      await update(15, SyncStep.encounterCategories);
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
      AppLog.e('Sync', 'encounterCategorie failed', e);

      rethrow;
    }

    if (update != null) {
      await update(20, SyncStep.behaviouralStates);
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
      AppLog.e('Sync', 'BehaviouralState failed', e);

      rethrow;
    }

    if (update != null) {
      await update(25, SyncStep.sightings);
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
      AppLog.e('Sync', 'TrackingAreaHomeData failed', e);

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
          await update(percentUpdate.toInt(), SyncStep.sightings);
        }

        SightingSaveResponse? saveResponse;

        try {
          saveResponse = await api.saveSighting(sighting, speciesController.getSpeciesById);

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
          AppLog.e('Sync', 'sightingUpdate failed for sighting ${sighting.id}', ei);

          rethrow;
        }

        if (update != null) {
          var percentStep2 = 100*(index*2)/(count*2);
          var percentUpdate2 = (percentStep2*75)/100;
          await update(percentUpdate2.toInt(), SyncStep.sightingImages);
        }

        if (sighting.image != null && sighting.image != "") {
          try {
            if (!await api.existSightingImage(sighting.unid!, sighting.image!)) {
              await api.saveSightingImage(sighting.unid!, sighting.image!);
            }
          } catch(ei) {
            AppLog.w('Sync', 'image upload failed', ei);
          }
        }

        /// delete old sighting ------------------------------------------------

        if (saveResponse != null) {
          if (saveResponse.unid != null) {
            if (saveResponse.canDelete != null) {
              if (saveResponse.canDelete!) {
                if (sighting.image != null && sighting.image != "") {
                  AppLog.i('Sync', 'tracking: delete image from sighting: ${sighting.image}');

                  File(sighting.image!).delete();
                }

                AppLog.i('Sync', 'tracking: delete sighting: ${sighting.unid}');

                DBHelper.deleteSighting(sighting);
              }
            } else {
              AppLog.d('Sync', 'sighting ${sighting.unid}: canDelete not set');
            }
          } else {
            AppLog.i('Sync', 'tracking: SightingSaveResponse unid is empty');
          }
        } else {
          AppLog.i('Sync', 'tracking: SightingSaveResponse is empty');
        }
      }
    } catch(e) {
      AppLog.e('Sync', 'sightings upload failed', e);

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
            await uploadTourTracking(
              tourFId,
              api.saveSightingTourTracking,
              progress: (sent, total) async {
                if (update != null) {
                  await update(90, SyncStep.tracking, '$sent/$total');
                }
              },
            );
          } else {
            AppLog.d('Sync', 'tracking $tourFId: isComplete $isComplete');

            await DBHelper.setTourTrackingSynced(tourFId, true);

            // Delete the local copy once the server has all points and either
            // allows it (canDelete) or the tour is older than the local
            // retention - the server only sets canDelete for very old tours.
            var canDeleteLocal = UtilTourTracking.canDeleteLocal(
              isComplete: isComplete,
              canDelete: checkResponse.canDelete,
              latestDate: await DBHelper.latestTourTrackingDate(tourFId),
              now: DateTime.now(),
            );

            if (canDeleteLocal) {
              AppLog.i('Sync', 'tracking: delete tracking entries by tourFId: $tourFId');

              await DBHelper.deleteTourTrackingEntries(tourFId);
            }
          }
        } else {
          AppLog.i('Sync', 'tracking: SightingTourTrackingCheck return null');
        }
      } catch(e) {
        AppLog.e('Sync', 'tracking failed', e);

        rethrow;
      }
    }

    /// ------------------------------------------------------------------------

    if (update != null) {
      await update(100, SyncStep.finish);
    }
  }
}