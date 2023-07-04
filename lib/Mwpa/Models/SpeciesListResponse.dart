import 'package:mwpaapp/Models/Species.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

/// SpeciesListResponse
class SpeciesListResponse extends DefaultReturn {
  final List<Species>? list;

  SpeciesListResponse({required super.statusCode, super.msg, this.list});

  /// fromJson
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
          id: 0,
          orgid: UtilCheckJson.checkValue(element['id'], UtilCheckJsonTypes.int),
          name: UtilCheckJson.checkValue(element['name'], UtilCheckJsonTypes.string),
          isdeleted: UtilCheckJson.checkValue(element['isdeleted'], UtilCheckJsonTypes.int)
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