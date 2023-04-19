import 'package:mwpaapp/Models/Vehicle.dart';
import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

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
      List<Vehicle> tList = [];
      List<dynamic> vList = json['list'];

      for (var element in vList) {
        tList.add(Vehicle(
            id: UtilCheckJson.checkValue(element['id'], UtilCheckJsonTypes.int),
            name: UtilCheckJson.checkValue(element['name'], UtilCheckJsonTypes.string),
            isdeleted: UtilCheckJson.checkValue(element['isdeleted'], UtilCheckJsonTypes.int)
        ));
      }

      list = tList;
    }

    return VehicleResponse(
      statusCode: json['statusCode'],
      msg: msg,
      list: list
    );
  }
}