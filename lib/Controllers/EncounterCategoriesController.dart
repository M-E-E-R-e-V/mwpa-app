import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';

class EncounterCategoriesController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getEncounterCategorie();
  }

  var encounterCategorieList = <EncounterCategorie>[].obs;

  Future<int> addEncounterCategorie({required EncounterCategorie encCate}) async {
    return await DBHelper.insertEncounterCategorie(encCate);
  }

  Future<void> getEncounterCategorie() async {
    List<Map<String, dynamic>> encCats = await DBHelper.queryEncounterCategorie();
    encounterCategorieList.assignAll(encCats.map((data) => EncounterCategorie.fromJson(data)).toList());
  }
}