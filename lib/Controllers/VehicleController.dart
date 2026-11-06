import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Vehicle.dart';

/// VehicleController
class VehicleController extends ChangeNotifier {

  List<Vehicle> vehicleList = <Vehicle>[];

  Future<int> addVehicle({required Vehicle vehicle}) async {
    return await DBHelper.insertVehicle(vehicle);
  }

  Future<void> getVehicle() async {
    List<Map<String, dynamic>> vehicles = await DBHelper.queryVehicle(false);

    vehicleList = [
      Vehicle(id: 0, name: 'Unknown'),
      ...vehicles.map((data) => Vehicle.fromJson(data)),
    ];
    notifyListeners();
  }
}
