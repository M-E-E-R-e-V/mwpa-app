import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Sighting.dart';

class SightingController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  var sightingList = <Sighting>[].obs;

  /*Future<void> addSighting({Sighting sighting}) {

  }*/

  void getSightings() async {
    List<Map<String, dynamic>> sightings = await DBHelper.querySighting();
    sightingList.assignAll(sightings.map((data) => Sighting.fromJson(data)).toList());
  }
}