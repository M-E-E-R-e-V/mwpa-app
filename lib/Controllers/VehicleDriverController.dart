import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';

/// VehicleDriverController
class VehicleDriverController extends ChangeNotifier {

  List<VehicleDriver> vehicleDriverList = <VehicleDriver>[];

  Future<int> addVehicleDriver({required VehicleDriver driver}) async {
    return await DBHelper.insertVehicleDriver(driver);
  }

  Future<void> getVehicleDriver() async {
    List<Map<String, dynamic>> drivers = await DBHelper.queryVehicleDriver(false);
    vehicleDriverList = [
      VehicleDriver(id: 0, username: 'Unknown'),
      ...drivers.map((data) => VehicleDriver.fromJson(data)),
    ];
    notifyListeners();
  }
}
