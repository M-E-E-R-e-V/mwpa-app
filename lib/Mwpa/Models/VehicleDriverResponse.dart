import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

class VehicleDriverResponse extends DefaultReturn {
  final List<VehicleDriver>? list;

  VehicleDriverResponse({required super.statusCode, super.msg, this.list});

  factory VehicleDriverResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    List<VehicleDriver>? list;

    if (json.containsKey('list')) {
      List<VehicleDriver> tlist = [];

      List<dynamic> vlist = json['list'];

      for (var element in vlist) {
        tlist.add(VehicleDriver(
          id: UtilCheckJson.checkValue(element['id'], UtilCheckJsonTypes.int),
          userId: UtilCheckJson.checkValue(element['user']['user_id'], UtilCheckJsonTypes.int),
          description: UtilCheckJson.checkValue(element['description'], UtilCheckJsonTypes.string),
          username: UtilCheckJson.checkValue(element['user']['name'], UtilCheckJsonTypes.string),
          isdeleted: UtilCheckJson.checkValue(element['isdeleted'], UtilCheckJsonTypes.int)
        ));
      }

      list = tlist;
    }

    return VehicleDriverResponse(
        statusCode: json['statusCode'],
        msg: msg,
        list: list
    );
  }
}