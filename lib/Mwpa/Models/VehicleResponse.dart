import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class VehicleResponse extends DefaultReturn {
  final List<Vehicle>? list;

  VehicleResponse({required super.statusCode, super.msg, this.list});

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    List<Vehicle>? list;

    if (json.containsKey('list')) {
      List<Vehicle> tlist = [];

      List<dynamic> vlist = json['list'];

      for (var element in vlist) {
        tlist.add(Vehicle(
            id: element['id'],
            name: element['name'],
            isdeleted: element['isdeleted'] ? 1 : 0
        ));
      }

      list = tlist;
    }

    return VehicleResponse(
      statusCode: json['statusCode'],
      msg: msg,
      list: list
    );
  }
}