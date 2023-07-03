import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Species.dart';

/// SpeciesController
class SpeciesController extends GetxController {

  /// onReady
  @override
  void onReady() {
    super.onReady();
    getSpecies();
  }

  var speciesList = <Species>[].obs;

  /// addSpecies
  Future<int> addSpecies({required Species species}) async {
    return await DBHelper.insertSpecies(species);
  }

  /// getSpecies
  Future<void> getSpecies() async {
    List<Map<String, dynamic>> species = await DBHelper.querySpecies(false);
    speciesList.assignAll(species.map((data) => Species.fromJson(data)).toList());
  }

  /// getSpeciesName
  String? getSpeciesName(int id) {
    for (var specie in speciesList) {
      if (specie.id == id) {
        return specie.name;
      }
    }

    return null;
  }
}