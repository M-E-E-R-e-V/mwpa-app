import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';

class BehaviouralStateController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    getBehaviouralStates();
  }

  var behaviouralStateList = <BehaviouralState>[].obs;

  Future<int> addBehaviouralState({required BehaviouralState behState}) async {
    return await DBHelper.insertBehaviouralState(behState);
  }

  Future<void> getBehaviouralStates() async {
    List<Map<String, dynamic>> behStates = await DBHelper.queryBehaviouralState();
    behaviouralStateList.assignAll(behStates.map((data) => BehaviouralState.fromJson(data)).toList());
  }
}