import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// SightingController
class SightingController extends ChangeNotifier {

  List<Sighting> sightingList = <Sighting>[];

  /// addSighting
  Future<int> addSighting({required Sighting newSighting}) async {
    return await DBHelper.insertSighting(newSighting);
  }

  /// getSightings
  Future<void> getSightings() async {
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList = sightings.map((data) => Sighting.fromJson(data)).toList();
    notifyListeners();
  }

  /// delete
  Future<void> delete(Sighting oldSighting) async {
    await DBHelper.deleteSighting(oldSighting);

    AppLog.i('Sightings', 'deleted sighting ${oldSighting.id}');
  }

  /// updateSighting
  Future<int> updateSighting({required Sighting tSighting}) async {
    var result = await DBHelper.updateSighting(tSighting);
    notifyListeners();
    return result;
  }

  /// updateSightingEndtour
  Future<int> updateSightingEndtour(String tourFid, String tourend) async {
    var result = await DBHelper.updateSightingEndTour(tourFid, tourend);
    notifyListeners();
    return result;
  }
}