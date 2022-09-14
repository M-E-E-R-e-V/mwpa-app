import 'package:mwpaapp/Models/EncounterCategorie.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class EncounterCategoriesResponse extends DefaultReturn {
  final List<EncounterCategorie>? list;

  EncounterCategoriesResponse({required super.statusCode, super.msg, this.list});

  factory EncounterCategoriesResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    List<EncounterCategorie>? list;

    if (json.containsKey('list')) {
      List<EncounterCategorie> tlist = [];

      List<dynamic> vlist = json['list'];

      for (var element in vlist) {
        tlist.add(EncounterCategorie(
            id: element['id'],
            name: element['name']
        ));
      }

      list = tlist;
    }

    return EncounterCategoriesResponse(
        statusCode: json['statusCode'],
        msg: msg,
        list: list
    );
  }
}