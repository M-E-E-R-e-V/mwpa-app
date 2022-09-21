import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

class BehaviouralStatesResponse extends DefaultReturn {
  final List<BehaviouralState>? list;

  BehaviouralStatesResponse({required super.statusCode, super.msg, this.list});

  factory BehaviouralStatesResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    List<BehaviouralState>? list;

    if (json.containsKey('list')) {
      List<BehaviouralState> tlist = [];

      List<dynamic> vlist = json['list'];

      for (var element in vlist) {
        tlist.add(BehaviouralState(
          id: UtilCheckJson.checkValue(element['id'], UtilCheckJsonTypes.int),
          name: UtilCheckJson.checkValue(element['name'], UtilCheckJsonTypes.string),
          description: UtilCheckJson.checkValue(element['description'], UtilCheckJsonTypes.string),
          isdeleted: UtilCheckJson.checkValue(element['isdeleted'], UtilCheckJsonTypes.int)
        ));
      }

      list = tlist;
    }

    return BehaviouralStatesResponse(
        statusCode: json['statusCode'],
        msg: msg,
        list: list
    );
  }
}