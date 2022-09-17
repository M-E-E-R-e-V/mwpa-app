import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/Vehicle.dart';

class VehicleController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getVehicle();
  }

  var vehicleList = <Vehicle>[].obs;

  Future<int> addVehicle({required Vehicle vehicle}) async {
    return await DBHelper.insertVehicle(vehicle);
  }

  Future<void> getVehicle() async {
    List<Map<String, dynamic>> vehicles = await DBHelper.queryVehicle(false);
    vehicleList.assignAll(vehicles.map((data) => Vehicle.fromJson(data)).toList());
  }
}