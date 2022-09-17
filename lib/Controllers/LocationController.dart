import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Location/LocationProvider.dart';

class LocationController extends GetxController {

  @override
  void onReady() {
    super.onReady();
    locationTimer = scheduleTimeout(10 * 1000);
  }

  Timer? locationTimer;
  Position? currentPosition;

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer.periodic(Duration(milliseconds: milliseconds), callLocation);

  Future<void> callLocation(Timer time) async {
    try {
      var position = await LocationProvider.getLocation();
      currentPosition = position;
    } catch(e) {
      print(e);
    }
  }
}