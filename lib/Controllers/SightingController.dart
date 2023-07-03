import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Sighting.dart';

/// SightingController
class SightingController extends GetxController {

  /// onReady
  @override
  void onReady() {
    super.onReady();
    getSightings();
  }

  var sightingList = <Sighting>[].obs;

  /// addSighting
  Future<int> addSighting({required Sighting newSighting}) async {
    return await DBHelper.insertSighting(newSighting);
  }

  /// getSightings
  void getSightings() async {
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList.assignAll(sightings.map((data) => Sighting.fromJson(data)).toList());
  }

  /// delete
  Future<void> delete(Sighting oldSighting) async {
    var val = await DBHelper.deleteSighting(oldSighting);
    print(val);
  }

  /// updateSighting
  Future<int> updateSighting({required Sighting tSighting}) async {
    var result = await DBHelper.updateSighting(tSighting);
    update();
    return result;
  }

  /// updateSightingEndtour
  Future<int> updateSightingEndtour(String tourFid, String tourend) async {
    var result = await DBHelper.updateSightingEndTour(tourFid, tourend);
    update();
    return result;
  }
}