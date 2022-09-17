import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class SpeciesListResponse extends DefaultReturn {
  final List<Species>? list;

  SpeciesListResponse({required super.statusCode, super.msg, this.list});

  factory SpeciesListResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    List<Species>? list;

    if (json.containsKey('list')) {
      List<Species> tlist = [];

      List<dynamic> vlist = json['list'];

      for (var element in vlist) {
        tlist.add(Species(
          id: element['id'],
          name: element['name'],
          isdeleted: element['isdeleted'] ? 1 : 0
        ));
      }

      list = tlist;
    }

    return SpeciesListResponse(
        statusCode: json['statusCode'],
        msg: msg,
        list: list
    );
  }
}