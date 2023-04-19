import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/VehicleDriver.dart';

class VehicleDriverController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getVehicleDriver();
  }

  var vehicleDriverList = <VehicleDriver>[].obs;

  Future<int> addVehicleDriver({required VehicleDriver driver}) async {
    return await DBHelper.insertVehicleDriver(driver);
  }

  Future<void> getVehicleDriver() async {
    List<Map<String, dynamic>> drivers = await DBHelper.queryVehicleDriver(false);
    vehicleDriverList.assignAll(drivers.map((data) => VehicleDriver.fromJson(data)).toList());
    vehicleDriverList.insert(0, VehicleDriver(id: 0, username: 'Unknown'));
  }
}