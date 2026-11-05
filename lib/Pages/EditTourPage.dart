import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/BeaufortController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:provider/provider.dart';

class EditTourPage extends StatefulWidget {

  const EditTourPage({super.key});

  @override
  State<EditTourPage> createState() => _EditTourPageState();
}

class _EditTourPageState extends State<EditTourPage> {
  late final PrefController _prefController = context.read<PrefController>();
  late final VehicleController _vehicleController = context.read<VehicleController>();
  late final VehicleDriverController _vehicleDriverController = context.read<VehicleDriverController>();
  late final LocationController _locationController = context.read<LocationController>();

  late Widget sightVehicle;
  DynInputValue sightVehicleValue = DynInputValue();

  late Widget sightVehicleDriver;
  DynInputValue sightVehicleDriverValue = DynInputValue();

  late Widget sightBeaufort;
  DynInputValue sightBeaufortValue = DynInputValue();

  late Widget sightDate;
  DynInputValue sightDateValue = DynInputValue();

  late Widget sightTourStart;
  DynInputValue sightTourStartValue = DynInputValue();

  late Widget sightTourEnd;
  DynInputValue sightTourEndValue = DynInputValue();

  late Widget sightSetEndTour;
  DynInputValue sightSetEndTourValue = DynInputValue();

  late Widget sightUseHomeArea;
  DynInputValue sightUseHomeAreaValue = DynInputValue();

  bool isInit = false;

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Set default Tour'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          ConfirmDialog.show(
            context,
            'Tour close',
            'Close tour without saving? All changes will be lost!',
            (value) {
              if (value == 'ok') {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  /// save the settings
  Future<void> _saveTourToPref() async {
    TourPref tour = TourPref(
        vehicle_id: sightVehicleValue.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriverValue.getStrValueAsInt(),
        beaufort_wind: sightBeaufortValue.getValue(),
        date: sightDateValue.getDateTime(),
        tour_start: sightTourStartValue.getTimeOfDay(),
        tour_end: sightTourEndValue.getTimeOfDay(),
        set_end_tour: sightSetEndTourValue.getIntValue(),
        use_home_area: sightUseHomeAreaValue.getIntValue()
    );

    await _prefController.saveTour(tour);
    await _locationController.reloadSettings();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      isInit = true;

      if (_prefController.prefToru != null) {
        //  vehicle
        if (_vehicleController.vehicleList.map(
                (element) => element.id).contains(_prefController.prefToru!.vehicle_id!)
        ) {
          sightVehicleValue.setStrValueByInt(_prefController.prefToru!.vehicle_id!);
        }

        // vehicle driver
        if (_vehicleDriverController.vehicleDriverList.map(
                (element) => element.id).contains(_prefController.prefToru!.vehicle_driver_id!)
        ) {
          sightVehicleDriverValue.setStrValueByInt(_prefController.prefToru!.vehicle_driver_id!);
        }

        sightBeaufortValue.setValue(_prefController.prefToru!.beaufort_wind!);
        sightDateValue.setDateTime(_prefController.prefToru!.date!);
        sightTourStartValue.setTimeOfDy(_prefController.prefToru!.tour_start!);
        sightTourEndValue.setTimeOfDy(_prefController.prefToru!.tour_end!);
        sightSetEndTourValue.setIntValue(_prefController.prefToru!.set_end_tour!);
        sightUseHomeAreaValue.setIntValue(_prefController.prefToru!.use_home_area!);
      }
    }

    return ListenableBuilder(
      listenable: Listenable.merge([_vehicleController, _vehicleDriverController]),
      builder: (_, __) {
      sightVehicle = SelectInput(
        title: "Boat",
        value: sightVehicleValue,
        items: _vehicleController.vehicleList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
          );
        }).toList(),
      );

      sightVehicleDriver = SelectInput(
        title: "Skipper",
        value: sightVehicleDriverValue,
        items: _vehicleDriverController.vehicleDriverList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.username!
          );
        }).toList(),
      );

      sightBeaufort = SelectInput(
        title: "Wind/Sea-state (Beaufort)",
        value: sightBeaufortValue,
        items: BeaufortController.beaufortSelectList,
          searchable: false,
      );

      sightDate = DateInput(
        title: "Date",
        value: sightDateValue,
      );

      sightTourStart = TimeInput(
        title: "Start of trip",
        value: sightTourStartValue,
      );

      sightTourEnd = TimeInput(
        title: "End of trip",
        value: sightTourEndValue,
      );

      sightSetEndTour = SwitchInput(
        title: 'Allow tour end time button for all sightings',
        value: sightSetEndTourValue,
      );

      sightUseHomeArea = SwitchInput(
        title: 'Use Home Area auto-tracking tour start and end',
        value: sightUseHomeAreaValue,
      );

      return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: _appBar(context),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputSection(
                    title: 'Tour',
                    icon: Icons.directions_boat_outlined,
                    children: [
                      sightVehicle,
                      sightVehicleDriver,
                      sightBeaufort,
                      sightDate,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sightTourStart),
                          const SizedBox(width: 12),
                          Expanded(child: sightTourEnd),
                        ],
                      ),
                    ],
                  ),
                  InputSection(
                    title: 'Settings',
                    icon: Icons.tune,
                    children: [
                      sightSetEndTour,
                      sightUseHomeArea,
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _saveTourToPref,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save default Tour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

}