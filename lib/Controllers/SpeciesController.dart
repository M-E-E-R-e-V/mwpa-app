import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Species.dart';

/// SpeciesController
class SpeciesController extends ChangeNotifier {

  List<Species> speciesList = <Species>[];

  /// addSpecies
  Future<int> addSpecies({required Species species}) async {
    return await DBHelper.insertSpecies(species);
  }

  /// getSpecies
  Future<void> getSpecies() async {
    List<Map<String, dynamic>> species = await DBHelper.querySpecies(false);
    speciesList = species.map((data) => Species.fromDbJson(data)).toList();
    notifyListeners();
  }

  /// getSpeciesByOrgId - by server species id (what sightings store; the
  /// local row id is renumbered by every sync)
  Species? getSpeciesByOrgId(int orgid) {
    for (var specie in speciesList) {
      if (specie.orgid == orgid) {
        return specie;
      }
    }

    return null;
  }

  /// getSpeciesName
  String? getSpeciesName(int id) {
    for (var specie in speciesList) {
      if (specie.orgid == id) {
        return specie.name;
      }
    }

    return null;
  }
}