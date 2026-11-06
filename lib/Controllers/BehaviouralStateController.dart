import 'package:flutter/foundation.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Models/BehaviouralState.dart';

/// BehaviouralStateController
class BehaviouralStateController extends ChangeNotifier {

  List<BehaviouralState> behaviouralStateList = <BehaviouralState>[];

  /// marked as deleted on the server: not selectable any more, but old
  /// sightings still show them
  List<BehaviouralState> deletedBehaviouralStates = <BehaviouralState>[];

  /// addBehaviouralState
  Future<int> addBehaviouralState({required BehaviouralState behState}) async {
    return await DBHelper.insertBehaviouralState(behState);
  }

  /// getBehaviouralStates
  Future<void> getBehaviouralStates() async {
    List<Map<String, dynamic>> behStates = await DBHelper.queryBehaviouralState(false);
    behaviouralStateList = behStates.map((data) => BehaviouralState.fromJson(data)).toList();
    deletedBehaviouralStates = (await DBHelper.queryBehaviouralState(true))
        .where((data) => data['isdeleted'] == 1)
        .map((data) => BehaviouralState.fromJson(data))
        .toList();
    notifyListeners();
  }
}
