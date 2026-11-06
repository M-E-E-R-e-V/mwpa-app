import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/EncounterCategorie.dart';

/// EncounterCategoriesController
class EncounterCategoriesController extends ChangeNotifier {

  List<EncounterCategorie> encounterCategorieList = <EncounterCategorie>[];

  /// marked as deleted on the server: not selectable any more, but old
  /// sightings still show them
  List<EncounterCategorie> deletedEncounterCategories = <EncounterCategorie>[];

  Future<int> addEncounterCategorie({required EncounterCategorie encCate}) async {
    return await DBHelper.insertEncounterCategorie(encCate);
  }

  Future<void> getEncounterCategorie() async {
    List<Map<String, dynamic>> encCats = await DBHelper.queryEncounterCategorie(false);
    encounterCategorieList = encCats.map((data) => EncounterCategorie.fromJson(data)).toList();
    deletedEncounterCategories = (await DBHelper.queryEncounterCategorie(true))
        .where((data) => data['isdeleted'] == 1)
        .map((data) => EncounterCategorie.fromJson(data))
        .toList();
    notifyListeners();
  }
}
