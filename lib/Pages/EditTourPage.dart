import 'package:flutter/material.dart';
import 'package:mwpaapp/Components/HomeAreaMap.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/BeaufortController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/l10n/l10n.dart';

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

  late Widget keepScreenOn;
  DynInputValue keepScreenOnValue = DynInputValue();

  bool isInit = false;

  bool get _useHomeArea => sightUseHomeAreaValue.getIntValue() >= 1;

  /// _confirmClose - asks before leaving the page without saving; used by
  /// the app bar back button and the system back gesture/button
  void _confirmClose() {
    ConfirmDialog.show(
      context,
      context.l10n.settingsCloseTitle,
      context.l10n.settingsCloseQuestion,
      (value) {
        if (value == 'ok' && mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.settings),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _confirmClose,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  /// save the settings
  Future<void> _saveTourToPref() async {
    // with home area the app sets date and times itself (maybe while this
    // page was open): keep the stored ones instead of the read-only fields
    final current = _prefController.prefToru;
    final auto = _useHomeArea && current != null;

    TourPref tour = TourPref(
        vehicle_id: sightVehicleValue.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriverValue.getStrValueAsInt(),
        beaufort_wind: sightBeaufortValue.getValue(),
        date: auto ? current.date : sightDateValue.getDateTime(),
        tour_start: auto ? current.tour_start : sightTourStartValue.getTimeOfDay(),
        tour_end: auto ? current.tour_end : sightTourEndValue.getTimeOfDay(),
        set_end_tour: sightSetEndTourValue.getIntValue(),
        use_home_area: sightUseHomeAreaValue.getIntValue()
    );

    await _prefController.saveTour(tour);
    await _prefController.setKeepScreenOn(keepScreenOnValue.getIntValue() >= 1);
    await _locationController.reloadSettings();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// _homeAreaHint - what to do for the automatic tour, with the home area
  /// on a small map (or a note when it is not loaded yet)
  Widget _homeAreaHint(BuildContext context) {
    final theme = Theme.of(context);
    final homeArea = _locationController.homeArea;
    final loaded = homeArea.length >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              loaded ? Icons.info_outline : Icons.warning_amber_rounded,
              size: 20,
              color: loaded ? inputAccentColor(context) : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loaded ? context.l10n.homeAreaHint : context.l10n.homeAreaMissing,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (loaded) ...[
          const SizedBox(height: 10),
          HomeAreaMap(homeArea: homeArea),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      isInit = true;
      keepScreenOnValue.setIntValue(_prefController.keepScreenOn ? 1 : 0);

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
        title: context.l10n.labelBoat,
        value: sightVehicleValue,
        items: _vehicleController.vehicleList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
          );
        }).toList(),
      );

      sightVehicleDriver = SelectInput(
        title: context.l10n.labelSkipper,
        value: sightVehicleDriverValue,
        items: _vehicleDriverController.vehicleDriverList.map((element) {
          return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.username!
          );
        }).toList(),
      );

      sightBeaufort = SelectInput(
        title: context.l10n.labelBeaufort,
        value: sightBeaufortValue,
        items: BeaufortController.selectList(context.l10n.notSelected),
          searchable: false,
      );

      // with home area the app fills date and times itself
      final manualTimes = !_useHomeArea;

      sightDate = DateInput(
        title: context.l10n.fieldDate,
        value: sightDateValue,
        enabled: manualTimes,
      );

      sightTourStart = TimeInput(
        title: context.l10n.fieldTourStart,
        value: sightTourStartValue,
        enabled: manualTimes,
      );

      sightTourEnd = TimeInput(
        title: context.l10n.fieldTourEnd,
        value: sightTourEndValue,
        enabled: manualTimes,
      );

      sightSetEndTour = SwitchInput(
        title: context.l10n.labelAllowTourEnd,
        value: sightSetEndTourValue,
      );

      sightUseHomeArea = SwitchInput(
        title: context.l10n.labelUseHomeArea,
        value: sightUseHomeAreaValue,
        onChange: () => setState(() {}),
      );

      keepScreenOn = SwitchInput(
        title: context.l10n.labelKeepScreenOn,
        value: keepScreenOnValue,
      );

      return PopScope(
        canPop: false,
        // system back (button or gesture) asks like the app bar arrow
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _confirmClose();
          }
        },
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
                    title: context.l10n.sectionDefaultTour,
                    icon: Icons.directions_boat_outlined,
                    description: context.l10n.sectionDefaultTourInfo,
                    children: [
                      sightVehicle,
                      sightVehicleDriver,
                      sightBeaufort,
                    ],
                  ),
                  InputSection(
                    title: context.l10n.sectionTourTimes,
                    icon: Icons.schedule,
                    description: context.l10n.sectionTourTimesInfo,
                    children: [
                      sightUseHomeArea,
                      if (_useHomeArea) ...[
                        const SizedBox(height: 12),
                        _homeAreaHint(context),
                      ],
                      sightDate,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sightTourStart),
                          const SizedBox(width: 12),
                          Expanded(child: sightTourEnd),
                        ],
                      ),
                      // the "Tour End" button only exists without home area
                      if (!_useHomeArea) sightSetEndTour,
                    ],
                  ),
                  InputSection(
                    title: context.l10n.sectionSettings,
                    icon: Icons.tune,
                    children: [
                      keepScreenOn,
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _saveTourToPref,
                    icon: const Icon(Icons.save_alt),
                    label: Text(context.l10n.saveSettings),
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