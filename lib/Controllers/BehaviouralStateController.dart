import 'package:get/get.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';

/// BehaviouralStateController
class BehaviouralStateController extends GetxController {

  /// onReady
  @override
  void onReady() {
    super.onReady();
    getBehaviouralStates();
  }

  var behaviouralStateList = <BehaviouralState>[].obs;

  /// addBehaviouralState
  Future<int> addBehaviouralState({required BehaviouralState behState}) async {
    return await DBHelper.insertBehaviouralState(behState);
  }

  /// getBehaviouralStates
  Future<void> getBehaviouralStates() async {
    List<Map<String, dynamic>> behStates = await DBHelper.queryBehaviouralState(false);
    behaviouralStateList.assignAll(behStates.map((data) => BehaviouralState.fromJson(data)).toList());
  }
}