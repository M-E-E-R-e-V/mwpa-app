import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';

/// BehaviouralStateController
class BehaviouralStateController extends ChangeNotifier {

  List<BehaviouralState> behaviouralStateList = <BehaviouralState>[];

  /// addBehaviouralState
  Future<int> addBehaviouralState({required BehaviouralState behState}) async {
    return await DBHelper.insertBehaviouralState(behState);
  }

  /// getBehaviouralStates
  Future<void> getBehaviouralStates() async {
    List<Map<String, dynamic>> behStates = await DBHelper.queryBehaviouralState(false);
    behaviouralStateList = behStates.map((data) => BehaviouralState.fromJson(data)).toList();
    notifyListeners();
  }
}
