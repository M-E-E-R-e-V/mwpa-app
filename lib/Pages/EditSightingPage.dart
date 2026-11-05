import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/BeaufortController.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// EditSightingPage
class EditSightingPage extends StatefulWidget {
  final Sighting? sighting;

  const EditSightingPage({super.key, this.sighting});

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

/// _EditSightingPageState
class _EditSightingPageState extends State<EditSightingPage> {
  late final PrefController _prefController = context.read<PrefController>();
  late final LocationController _locationController = context.read<LocationController>();
  late final SightingController _sightingController = context.read<SightingController>();
  late final VehicleController _vehicleController = context.read<VehicleController>();
  late final VehicleDriverController _vehicleDriverController = context.read<VehicleDriverController>();
  late final SpeciesController _speciesController = context.read<SpeciesController>();
  late final EncounterCategoriesController _encounterCategoriesController = context.read<EncounterCategoriesController>();
  late final BehaviouralStateController _behaviouralStateController = context.read<BehaviouralStateController>();

  bool isInit = false;

  String title = "";

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

  late Widget sightDurationFrom;
  DynInputValue sightDurationFromValue = DynInputValue();

  late Widget sightDurationUntil;
  DynInputValue sightDurationUntilValue = DynInputValue();

  late Widget sightLocationBegin;
  DynInputValue sightLocationBeginValue = DynInputValue();

  late Widget sightLocationEnd;
  DynInputValue sightLocationEndValue = DynInputValue();

  late Widget sightPhotoTaken;
  DynInputValue sightPhotoTakenValue = DynInputValue();

  late Widget sightDistanceCoast;
  DynInputValue sightDistanceCoastValue = DynInputValue();

  late Widget sightDistanceCoastEstimationGps;
  DynInputValue sightDistanceCoastEstimationGpsValue = DynInputValue();

  late Widget sightSpecies;
  DynInputValue sightSpeciesValue = DynInputValue();

  late Widget sightSpeciesNum;
  DynInputValue sightSpeciesNumValue = DynInputValue();

  late Widget sightJuveniles;
  DynInputValue sightJuvenilesValue = DynInputValue();

  late Widget sightCalves;
  DynInputValue sightCalvesValue = DynInputValue();

  late Widget sightNewborns;
  DynInputValue sightNewbornsValue = DynInputValue();

  late Widget sightBehaviour;
  DynInputValue sightBehaviourValue = DynInputValue();

  late Widget sightSubgroups;
  DynInputValue sightSubgroupsValue = DynInputValue();

  late Widget sightGroupStructure;
  DynInputValue sightGroupStructureValue = DynInputValue();

  late Widget sightReaction;
  DynInputValue sightReactionValue = DynInputValue();

  late Widget sightFreqBehaviour;
  DynInputValue sightFreqBehaviourValue = DynInputValue();

  late Widget sightRecAnimals;
  DynInputValue sightRecAnimalsValue = DynInputValue();

  late Widget sightOtherSpecies;
  DynInputValue sightOtherSpeciesValue = DynInputValue();

  late Widget sightOther;
  DynInputValue sightOtherValue = DynInputValue();

  late Widget sightOtherVehicle;
  DynInputValue sightOtherVehicleValue = DynInputValue();

  late Widget sightNote;
  DynInputValue sightNoteValue = DynInputValue();

  late Widget sightImage;
  DynInputValue sightImageValue = DynInputValue();

  /// _appBar
  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(title.isEmpty ? 'Sighting' : title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          ConfirmDialog.show(
            context,
            'Sighting close',
            'Close sighting without saving? All changes will be lost!',
            (value) {
              if (value == 'ok') {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DefaultButton(
            buttonIcon: Icons.save_alt,
            height: 40,
            label: 'Save',
            onTab: _saveSightingToDb,
          ),
        ),
      ],
    );
  }

  /// _saveSightingToDb
  Future<void> _saveSightingToDb() async {
    var mUnid = "";

    if (widget.sighting != null) {
      mUnid = widget.sighting?.unid ?? "";
    }

    var pref = Preference();
    await pref.load();

    Sighting tSigh = Sighting(
      unid: mUnid,
      creater_id: pref.getUserId(),
      vehicle_id: sightVehicleValue.getStrValueAsInt(),
      vehicle_driver_id: sightVehicleDriverValue.getStrValueAsInt(),
      beaufort_wind: sightBeaufortValue.getValue(),
      date: sightDateValue.getDateTime(),
      tour_start: sightTourStartValue.getTimeOfDay(),
      tour_end: sightTourEndValue.getTimeOfDay(),
      duration_from: sightDurationFromValue.getTimeOfDay(),
      duration_until: sightDurationUntilValue.getTimeOfDay(),
      location_begin: sightLocationBeginValue.getPosition(),
      location_end: sightLocationEndValue.getPosition(),
      photo_taken: sightPhotoTakenValue.getIntValue(),
      distance_coast: sightDistanceCoastValue.getValue(),
      distance_coast_estimation_gps: sightDistanceCoastEstimationGpsValue
          .getIntValue(),
      species_id: sightSpeciesValue.getStrValueAsInt(),
      species_count: sightSpeciesNumValue.getStrValueAsInt(),
      juveniles: sightJuvenilesValue.getIntValue(),
      calves: sightCalvesValue.getIntValue(),
      newborns: sightNewbornsValue.getIntValue(),
      behaviours: sightBehaviourValue.getMultiValue(),
      subgroups: sightSubgroupsValue.getIntValue(),
      group_structure_id: sightGroupStructureValue.getStrValueAsInt(),
      reaction_id: sightReactionValue.getStrValueAsInt(),
      freq_behaviour: sightFreqBehaviourValue.getValue(),
      recognizable_animals: sightRecAnimalsValue.getValue(),
      other_species: sightOtherSpeciesValue.getMultiValue(),
      other: sightOtherValue.getValue(),
      other_vehicle: sightOtherVehicleValue.getValue(),
      note: sightNoteValue.getValue(),
      image: sightImageValue.getImagePath(),
      syncStatus: Sighting.SYNC_STATUS_OPEN
    );

    tSigh.tour_fid = UtilTourFid.createSTourFId(tSigh);

    if (widget.sighting != null) {
      tSigh.id = widget.sighting?.id!;

      var result = await _sightingController.updateSighting(tSighting: tSigh);

      if (kDebugMode) {
        print(result);
      }
    } else {
      await _sightingController.addSighting(newSighting: tSigh);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// _loadPref
  Future<void> _loadPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        if (prefs.containsKey(Preference.TOUR)) {
          TourPref tour = TourPref.fromJson(
              jsonDecode(prefs.getString(Preference.TOUR)!));

          //  vehicle
          if (_vehicleController.vehicleList.map(
                  (element) => element.id).contains(tour.vehicle_id!)
          ) {
            sightVehicleValue.setStrValueByInt(tour.vehicle_id!);
          }

          // vehicle driver
          if (_vehicleDriverController.vehicleDriverList.map(
                  (element) => element.id).contains(tour.vehicle_driver_id!)
          ) {
            sightVehicleDriverValue.setStrValueByInt(tour.vehicle_driver_id!);
          }

          sightBeaufortValue.setValue(tour.beaufort_wind!);
          sightDateValue.setDateTime(tour.date!);
          sightTourStartValue.setTimeOfDy(tour.tour_start!);
          sightTourEndValue.setTimeOfDy(tour.tour_end!);
        }
      });
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// _setLocationByTime
  Future<void> _setLocationByTime(BuildContext context, TimeOfDay aTimeOfDay, Function onSet) async {
    if (widget.sighting == null) {
      return;
    }

    if (_prefController.prefToru != null) {
      DateTime tDate = DateTime(
          sightDateValue.dateValue.year,
          sightDateValue.dateValue.month,
          sightDateValue.dateValue.day,
          aTimeOfDay.hour,
          aTimeOfDay.minute
      );

      Position? aPos = await _locationController.getLocationBy(
          UtilTourFid.createTTourFId(_prefController.prefToru!),
          tDate
      );

      if (aPos != null && context.mounted) {
        ConfirmDialog.show(
          context,
          "Position is found", "At this time a position was found for the current tour. Should this be used as the position?",
              (p0) {
            if (p0 == "ok") {
              onSet(aPos);
            }
          });
      }
    }
  }

  /// initState
  @override
  void initState() {
    super.initState();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      isInit = true;
      Sighting? sighting = widget.sighting;

      title = "Add Sighting";

      if (sighting != null) {
        title = "Edit Sighting";
        sightVehicleValue.setStrValueByInt(sighting.vehicle_id!);
        sightVehicleDriverValue.setStrValueByInt(sighting.vehicle_driver_id!);
        sightBeaufortValue.setValue(sighting.beaufort_wind!);
        sightDateValue.setDateTime(sighting.date!);
        sightTourStartValue.setTimeOfDy(sighting.tour_start!);
        sightTourEndValue.setTimeOfDy(sighting.tour_end!);
        sightDurationFromValue.setTimeOfDy(sighting.duration_from!);
        sightDurationUntilValue.setTimeOfDy(sighting.duration_until!);
        sightLocationBeginValue.setPositionStr(sighting.location_begin!);
        sightLocationEndValue.setPositionStr(sighting.location_end!);
        sightPhotoTakenValue.setIntValue(sighting.photo_taken!);
        sightDistanceCoastValue.setValue(sighting.distance_coast!);
        sightDistanceCoastEstimationGpsValue.setIntValue(
            sighting.distance_coast_estimation_gps!);
        sightSpeciesValue.setStrValueByInt(sighting.species_id!);
        sightSpeciesNumValue.setStrValueByInt(sighting.species_count!);
        sightJuvenilesValue.setIntValue(sighting.juveniles!);
        sightCalvesValue.setIntValue(sighting.calves!);
        sightNewbornsValue.setIntValue(sighting.newborns!);
        sightBehaviourValue.setMultiValue(sighting.behaviours!);
        sightSubgroupsValue.setIntValue(sighting.subgroups!);
        sightGroupStructureValue.setStrValueByInt(sighting.group_structure_id!);
        sightReactionValue.setStrValueByInt(sighting.reaction_id!);
        sightFreqBehaviourValue.setValue(sighting.freq_behaviour!);
        sightRecAnimalsValue.setValue(sighting.recognizable_animals!);
        sightOtherSpeciesValue.setMultiValue(sighting.other_species!);
        sightOtherValue.setValue(sighting.other!);
        sightOtherVehicleValue.setValue(sighting.other_vehicle!);
        sightNoteValue.setValue(sighting.note!);
        sightImageValue.setImagePath(sighting.image!);
      } else {
        _loadPref();

        // vehicle -------------------------------------------------------------
        // set as default when list have only one element
        if (_vehicleController.vehicleList.length == 1) {
          sightVehicleValue.setStrValueByInt(_vehicleController.vehicleList[0].id!);
        }

        // vehicle driver ------------------------------------------------------
        // set as default when list have only one element
        if (_vehicleDriverController.vehicleDriverList.length == 1) {
          sightVehicleDriverValue.setStrValueByInt(_vehicleDriverController.vehicleDriverList[0].id!);
        }

        sightDurationFromValue.setTimeof(TimeOfDay.now());
        sightJuvenilesValue.setIntValue(-1);
        sightCalvesValue.setIntValue(-1);
        sightNewbornsValue.setIntValue(-1);
        sightSubgroupsValue.setIntValue(-1);

        if (_locationController.currentPosition != null) {
          sightLocationBeginValue.setPosition(
              _locationController.currentPosition!);

          var distance = UtilDistanceCoast.getDistance(
              _locationController.currentPosition!);
          sightDistanceCoastValue.setValue("$distance");
        }
      }
    }

    return ListenableBuilder(
      listenable: Listenable.merge([
        _vehicleController,
        _vehicleDriverController,
        _speciesController,
        _encounterCategoriesController,
        _behaviouralStateController,
      ]),
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

         sightDurationFrom = TimeInput(
           title: "Sighting duration: from",
           value: sightDurationFromValue,
           onChange: () {
             if (sightLocationBeginValue.posValue == null) {
               setState(() {
                 sightLocationBeginValue.posValue = _locationController.currentPosition!;
               });
             } else {
               _setLocationByTime(
                   context,
                   sightDurationFromValue.timeValue!,
                       (Position aPos) {
                     setState(() {
                       sightLocationBeginValue.setPosition(aPos);
                     });
                   }
               );
             }
           },
         );

         sightDurationUntil = TimeInput(
           title: "until",
           value: sightDurationUntilValue,
           onChange: () async {
             _setLocationByTime(
                 context,
                 sightDurationUntilValue.timeValue!,
                 (Position aPos) {
                   setState(() {
                     sightLocationEndValue.setPosition(aPos);
                   });
                 }
               );
           },
         );

         sightLocationBegin = LocationInput(
           title: "Position begin",
           value: sightLocationBeginValue,
           onChange: () {
             if (sightLocationBeginValue.posValue != null) {
               var distance = UtilDistanceCoast.getDistance(sightLocationBeginValue.posValue!);
               sightDistanceCoastValue.setValue("$distance");
             }
           },
         );

         sightLocationEnd = LocationInput(
           title: "Position end",
           value: sightLocationEndValue,
         );

         sightPhotoTaken = SwitchInput(
           title: "Photos taken",
           value: sightPhotoTakenValue,
         );

         sightDistanceCoast = TextValueInput(
           title: "Distance to nearest coast (nm)",
           value: sightDistanceCoastValue,
           kind: TextValueKind.decimal,
           onFormat: (value) {
             try {
               var fValue = double.parse(value.strValue.replaceAll(RegExp(r'[^0-9.]'), ''));
               fValue = 0.5399568035 * (fValue / 1000);

               // same as GetX toPrecision(2): round to 2 digits, drop trailing zeros
               return "${double.parse(fValue.toStringAsFixed(2))}";
             } catch(e) {
               if (kDebugMode) {
                 print(e);
               }
             }

             return "0.0";
           },
         );

         sightDistanceCoastEstimationGps = SwitchInput(
           title: "Estimation without GPS",
           value: sightDistanceCoastEstimationGpsValue,
         );

         sightSpecies = SelectInput(
           title: "Species",
           value: sightSpeciesValue,
           items: _speciesController.speciesList.map((element) {
             var labelName = element.name!;

             if (element.name!.indexOf(',') > 0) {
               labelName = element.name!.split(",")[0];
             }

             return DynInputSelectItem(
                 value: element.orgid!.toString(),
                 label: labelName
             );
           }).toList(),
         );

         sightSpeciesNum = TextValueInput(
           title: "Number of animals",
           value: sightSpeciesNumValue,
           kind: TextValueKind.digits,
         );

         sightJuveniles = YesNoUnknownInput(
           title: 'Juveniles',
           value: sightJuvenilesValue,
         );

         sightCalves = YesNoUnknownInput(
           title: 'Calves',
           value: sightCalvesValue,
         );

         sightNewborns = YesNoUnknownInput(
           title: 'Newborns',
           value: sightNewbornsValue,
         );

         sightBehaviour = MultiSelectInput(
           title: 'Behaviour',
           value: sightBehaviourValue,
           items: _behaviouralStateController.behaviouralStateList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList(),
         );

         sightSubgroups = YesNoUnknownInput(
           title: 'Subgroups',
           value: sightSubgroupsValue,
         );

        sightGroupStructure = SelectInput(
          title: 'Group Structure',
          value: sightGroupStructureValue,
          items: [
            DynInputSelectItem(value: "1", label: "widely dispersed"),
            DynInputSelectItem(value: "2", label: "dispersed"),
            DynInputSelectItem(value: "3", label: "loose"),
            DynInputSelectItem(value: "4", label: "tight"),
          ],
        );

         sightReaction = SelectInput(
           title: 'Reaction',
           value: sightReactionValue,
           items: _encounterCategoriesController.encounterCategorieList.map((element) {
            return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
            );
          }).toList(),
         );

        sightFreqBehaviour = TagInput(
          title: "Frequent behaviours of individuals",
          value: sightFreqBehaviourValue,
          suggestions: const ['Test', 'SLP', 'SPY'],
        );

        sightRecAnimals = TextValueInput(
          title: "Recognizable animals",
          value: sightRecAnimalsValue,
          kind: TextValueKind.textarea,
        );

        sightOtherSpecies = MultiSelectInput(
          title: 'Other Species',
          value: sightOtherSpeciesValue,
          items: _speciesController.speciesList.map((element) {
            var labelName = element.name!;

            if (element.name!.indexOf(',') > 0) {
              labelName = element.name!.split(",")[0];
            }

            return DynInputSelectItem(
                value: element.id!.toString(),
                label: labelName
            );
          }).toList(),
        );

        sightOther = TextValueInput(
          title: "Other",
          value: sightOtherValue,
          kind: TextValueKind.textarea,
        );

        sightOtherVehicle = TextValueInput(
          title: "Other boats present",
          value: sightOtherVehicleValue,
          kind: TextValueKind.textarea,
        );

        sightNote = TextValueInput(
          title: "Note",
          value: sightNoteValue,
          kind: TextValueKind.textarea,
        );

        sightImage = ImageInput(
          title: "Picture",
          value: sightImageValue,
        );

         return PopScope(
           canPop: false,
           child: Scaffold(
             appBar: _appBar(context),
             body: SingleChildScrollView(
               padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   sightVehicle,
                   sightVehicleDriver,
                   sightBeaufort,
                   sightDate,
                   Row(
                     children: [
                       Expanded(child: sightTourStart),
                       const SizedBox(width: 12),
                       Expanded(child: sightTourEnd),
                     ],
                   ),
                   Row(
                     children: [
                       Expanded(child: sightDurationFrom),
                       const SizedBox(width: 12),
                       Expanded(child: sightDurationUntil),
                     ],
                   ),
                   sightLocationBegin,
                   sightLocationEnd,
                   sightDistanceCoast,
                   Row(
                     children: [
                       Expanded(child: sightPhotoTaken),
                       const SizedBox(width: 12),
                       Expanded(child: sightDistanceCoastEstimationGps),
                     ],
                   ),
                   sightSpecies,
                   sightSpeciesNum,
                   sightJuveniles,
                   sightCalves,
                   sightNewborns,
                   sightBehaviour,
                   sightSubgroups,
                   sightGroupStructure,
                   sightReaction,
                   sightFreqBehaviour,
                   sightRecAnimals,
                   sightOtherSpecies,
                   sightOther,
                   sightOtherVehicle,
                   sightNote,
                   sightImage,
                   const SizedBox(height: 24),
                   FilledButton.icon(
                     onPressed: _saveSightingToDb,
                     icon: const Icon(Icons.save_alt),
                     label: const Text('Save Sighting'),
                   ),
                   const SizedBox(height: 24),
                 ],
               ),
             ),
           ),
         );
     });
  }
}
