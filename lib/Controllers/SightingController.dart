import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Sighting.dart';

class SightingController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getSightings();
  }

  var sightingList = <Sighting>[].obs;

  Future<int> addSighting({required Sighting newSighting}) async {
    return await DBHelper.insertSighting(newSighting);
  }

  void getSightings() async {
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList.assignAll(sightings.map((data) => Sighting.fromJson(data)).toList());
  }

  Future<void> delete(Sighting oldSighting) async {
    var val = await DBHelper.deleteSighting(oldSighting);
    print(val);
  }

  Future<int> updateSighting({required Sighting tSighting}) async {
    return await DBHelper.updateSighting(tSighting);
  }
}