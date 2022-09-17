import 'package:mwpaapp/Models/BehaviouralState.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

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
          id: element['id'],
          name: element['name'],
          description: element['description'],
          isdeleted: element['isdeleted'] ? 1 : 0
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