import 'package:mwpaapp/Models/VehicleDriver.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

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
          id: element['id'],
          user_id: element['user']['user_id'],
          description: element['description'],
          username: element['user']['name']
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