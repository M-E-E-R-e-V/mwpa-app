import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Species.dart';

class SpeciesController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  var speciesList = <Species>[].obs;

  Future<int> addSpecies({required Species species}) async {
    return await DBHelper.insertSpecies(species);
  }
}