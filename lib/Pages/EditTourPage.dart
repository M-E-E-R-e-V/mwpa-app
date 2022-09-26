import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Components/DynInput.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTourPage extends StatefulWidget {

  const EditTourPage({Key? key}) : super(key: key);

  @override
  State<EditTourPage> createState() => _EditTourPageState();
}

class _EditTourPageState extends State<EditTourPage> {
  final PrefController _prefController = Get.find<PrefController>();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final VehicleDriverController _vehicleDriverController = Get.find<VehicleDriverController>();

  late DynInput sightVehicle;
  DynInputValue sightVehicleValue = DynInputValue();

  late DynInput sightVehicleDriver;
  DynInputValue sightVehicleDriverValue = DynInputValue();

  late DynInput sightBeaufort;
  DynInputValue sightBeaufortValue = DynInputValue();

  late DynInput sightDate;
  DynInputValue sightDateValue = DynInputValue();

  late DynInput sightTourStart;
  DynInputValue sightTourStartValue = DynInputValue();

  late DynInput sightTourEnd;
  DynInputValue sightTourEndValue = DynInputValue();

  late DynInput sightSetEndTour;
  DynInputValue sightSetEndTourValue = DynInputValue();

  _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryHeaderColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: kButtonFontColor,
        ),
        onPressed: () async {
          ConfirmDialog.show(
              context,
              "Tour close",
              "Close tour without saving? All changes will be lost!",
                  (value) {
                if (value != null) {
                  if (value == 'ok') {
                    Get.back();
                  }
                }
              });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (_prefController.prefToru != null) {
      sightVehicleValue.setStrValueByInt(_prefController.prefToru!.vehicle_id!);
      sightVehicleDriverValue.setStrValueByInt(_prefController.prefToru!.vehicle_driver_id!);
      sightBeaufortValue.setStrValueByInt(_prefController.prefToru!.beaufort_wind!);
      sightDateValue.setDateTime(_prefController.prefToru!.date!);
      sightTourStartValue.setTimeOfDy(_prefController.prefToru!.tour_start!);
      sightTourEndValue.setTimeOfDy(_prefController.prefToru!.tour_end!);
      sightSetEndTourValue.setIntValue(_prefController.prefToru!.set_end_tour!);
    }
  }

  _saveTourToPref() async {
    TourPref tour = TourPref(
        vehicle_id: sightVehicle.dynValue?.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriver.dynValue
            ?.getStrValueAsInt(),
        beaufort_wind: sightBeaufort.dynValue?.getStrValueAsInt(),
        date: sightDate.dynValue?.getDateTime(),
        tour_start: sightTourStart.dynValue?.getTimeOfDay(),
        tour_end: sightTourEnd.dynValue?.getTimeOfDay(),
        set_end_tour: sightSetEndTour.dynValue?.getIntValue()
    );

    await _prefController.saveTour(tour);

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      sightVehicle = DynInput(
        context: context,
        title: "Boat",
        hint: "",
        inputType: DynInputType.select,
        dynValue: sightVehicleValue,
        selectList: _vehicleController.vehicleList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
          );
        }).toList(),
      );

      sightVehicleDriver = DynInput(
        context: context,
        title: "Skipper",
        hint: "",
        inputType: DynInputType.select,
        dynValue: sightVehicleDriverValue,
        selectList: _vehicleDriverController.vehicleDriverList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.username!
          );
        }).toList(),
      );

      sightBeaufort = DynInput(
          context: context,
          title: "Wind/Seastate (Beaufort)",
          hint: "",
          inputType: DynInputType.select,
          dynValue: sightBeaufortValue,
          selectList: [
            DynInputSelectItem(value: "0", label: "0"),
            DynInputSelectItem(value: "1", label: "1"),
            DynInputSelectItem(value: "2", label: "2"),
            DynInputSelectItem(value: "3", label: "3"),
            DynInputSelectItem(value: "4", label: "4"),
            DynInputSelectItem(value: "5", label: "5"),
            DynInputSelectItem(value: "6", label: "6"),
            DynInputSelectItem(value: "7", label: "7"),
            DynInputSelectItem(value: "8", label: "8"),
            DynInputSelectItem(value: "9", label: "9"),
            DynInputSelectItem(value: "10", label: "10"),
            DynInputSelectItem(value: "11", label: "11"),
            DynInputSelectItem(value: "12", label: "12"),
          ]
      );

      sightDate = DynInput(
        context: context,
        title: "Date",
        hint: "",
        inputType: DynInputType.date,
        dynValue: sightDateValue,
      );

      sightTourStart = DynInput(
        context: context,
        title: "Start of trip",
        hint: "",
        inputType: DynInputType.time,
        dynValue: sightTourStartValue,
      );

      sightTourEnd = DynInput(
        context: context,
        title: "End of trip",
        hint: "",
        inputType: DynInputType.time,
        dynValue: sightTourEndValue,
      );

      sightSetEndTour = DynInput(
        context: context,
        hint: "",
        inputType: DynInputType.switcher,
        title: 'Allow tour end time button for all sightings',
        dynValue: sightSetEndTourValue,
      );

      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: _appBar(context),
          body: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set default Tour",
                      style: headingStyle,
                    ),
                    sightVehicle,
                    sightVehicleDriver,
                    sightBeaufort,
                    sightDate,
                    Row(
                      children: [
                        Expanded(
                            child: sightTourStart
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: sightTourEnd
                        )
                      ],
                    ),
                    sightSetEndTour,
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(),
                        DefaultButton(
                          buttonIcon: Icons.save_alt,
                          label: "Save default Tour",
                          onTab: () {
                            _saveTourToPref();
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ]
              ),
            ),
          ),
        ),
      );
    });
  }

}