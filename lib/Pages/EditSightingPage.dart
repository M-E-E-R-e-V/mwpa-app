import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DynInput.dart';
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

class EditSightingPage extends StatefulWidget {
  final Sighting? sighting;

  const EditSightingPage({Key? key, this.sighting}) : super(key: key);

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

class _EditSightingPageState extends State<EditSightingPage> {
  final PrefController _prefController = Get.find<PrefController>();
  final LocationController _locationController = Get.find<LocationController>();
  final SightingController _sightingController = Get.find<SightingController>();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final VehicleDriverController _vehicleDriverController = Get.find<VehicleDriverController>();
  final SpeciesController _speciesController = Get.find<SpeciesController>();
  final EncounterCategoriesController _encounterCategoriesController = Get.find<EncounterCategoriesController>();
  final BehaviouralStateController _behaviouralStateController = Get.find<BehaviouralStateController>();

  String title = "";

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

  late DynInput sightDurationFrom;
  DynInputValue sightDurationFromValue = DynInputValue();

  late DynInput sightDurationUntil;
  DynInputValue sightDurationUntilValue = DynInputValue();

  late DynInput sightLocationBegin;
  DynInputValue sightLocationBeginValue = DynInputValue();

  late DynInput sightLocationEnd;
  DynInputValue sightLocationEndValue = DynInputValue();

  late DynInput sightPhotoTaken;
  DynInputValue sightPhotoTakenValue = DynInputValue();

  late DynInput sightDistanceCoast;
  DynInputValue sightDistanceCoastValue = DynInputValue();

  late DynInput sightDistanceCoastEstimationGps;
  DynInputValue sightDistanceCoastEstimationGpsValue = DynInputValue();

  late DynInput sightSpecies;
  DynInputValue sightSpeciesValue = DynInputValue();

  late DynInput sightSpeciesNum;
  DynInputValue sightSpeciesNumValue = DynInputValue();

  late DynInput sightJuveniles;
  DynInputValue sightJuvenilesValue = DynInputValue();

  late DynInput sightCalves;
  DynInputValue sightCalvesValue = DynInputValue();

  late DynInput sightNewborns;
  DynInputValue sightNewbornsValue = DynInputValue();

  late DynInput sightBehaviour;
  DynInputValue sightBehaviourValue = DynInputValue();

  late DynInput sightSubgroups;
  DynInputValue sightSubgroupsValue = DynInputValue();

  late DynInput sightGroupStructure;
  DynInputValue sightGroupStructureValue = DynInputValue();

  late DynInput sightReaction;
  DynInputValue sightReactionValue = DynInputValue();

  late DynInput sightFreqBehaviour;
  DynInputValue sightFreqBehaviourValue = DynInputValue();

  late DynInput sightRecAnimals;
  DynInputValue sightRecAnimalsValue = DynInputValue();

  late DynInput sightOtherSpecies;
  DynInputValue sightOtherSpeciesValue = DynInputValue();

  late DynInput sightOther;
  DynInputValue sightOtherValue = DynInputValue();

  late DynInput sightOtherVehicle;
  DynInputValue sightOtherVehicleValue = DynInputValue();

  late DynInput sightNote;
  DynInputValue sightNoteValue = DynInputValue();

  late DynInput sightImage;
  DynInputValue sightImageValue = DynInputValue();

  _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryHeaderColor,
      leading: DefaultButton(
        buttonIcon: Icons.arrow_back,
        height: 40,
        onTab: () async {
          ConfirmDialog.show(
              context,
              "Sighting close",
              "Close sighting without saving? All changes will be lost!",
                  (value) {
                if (value != null) {
                  if (value == 'ok') {
                    Get.back();
                  }
                }
              });
          //await Navigator.pushNamed(context, '/List');
        },
      ),
      actions: [
        DefaultButton(
            buttonIcon: Icons.save_alt,
            height: 40,
            label: "Save Sighting",
            onTab: () {
              _saveSightingToDb();
            }
        )
      ],
    );
  }

  _saveSightingToDb() async {
    Sighting tSigh = Sighting(
        unid: "",
        vehicle_id: sightVehicle.dynValue?.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriver.dynValue
            ?.getStrValueAsInt(),
        beaufort_wind: sightBeaufort.dynValue?.getStrValueAsInt(),
        date: sightDate.dynValue?.getDateTime(),
        tour_start: sightTourStart.dynValue?.getTimeOfDay(),
        tour_end: sightTourEnd.dynValue?.getTimeOfDay(),
        duration_from: sightDurationFrom.dynValue?.getTimeOfDay(),
        duration_until: sightDurationUntil.dynValue?.getTimeOfDay(),
        location_begin: sightLocationBegin.dynValue?.getPosition(),
        location_end: sightLocationEnd.dynValue?.getPosition(),
        photo_taken: sightPhotoTaken.dynValue?.getIntValue(),
        distance_coast: sightDistanceCoast.dynValue?.getValue(),
        distance_coast_estimation_gps: sightDistanceCoastEstimationGps
            .dynValue?.getIntValue(),
        species_id: sightSpecies.dynValue?.getStrValueAsInt(),
        species_count: sightSpeciesNum.dynValue?.getStrValueAsInt(),
        juveniles: sightJuveniles.dynValue?.getIntValue(),
        calves: sightCalves.dynValue?.getIntValue(),
        newborns: sightNewborns.dynValue?.getIntValue(),
        behaviours: sightBehaviour.dynValue?.getMultiValue(),
        subgroups: sightSubgroups.dynValue?.getIntValue(),
        group_structure_id: sightGroupStructure.dynValue?.getStrValueAsInt(),
        reaction_id: sightReaction.dynValue?.getStrValueAsInt(),
        freq_behaviour: sightFreqBehaviour.dynValue?.getValue(),
        recognizable_animals: sightRecAnimals.dynValue?.getValue(),
        other_species: sightOtherSpecies.dynValue?.getMultiValue(),
        other: sightOther.dynValue?.getValue(),
        other_vehicle: sightOtherVehicle.dynValue?.getValue(),
        note: sightNote.dynValue?.getValue(),
        image: sightImage.dynValue?.getImagePath()
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

    Get.back();
  }

  Future<void> _loadPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        if (prefs.containsKey(Preference.TOUR)) {
          TourPref tour = TourPref.fromJson(
              jsonDecode(prefs.getString(Preference.TOUR)!));

          sightVehicleValue.setStrValueByInt(tour.vehicle_id!);
          sightVehicleDriverValue.setStrValueByInt(tour.vehicle_driver_id!);
          sightBeaufortValue.setStrValueByInt(tour.beaufort_wind!);
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

  _setLocationByTime(BuildContext context, TimeOfDay aTimeOfDay, Function onSet) async {
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

      if (aPos != null) {
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

  @override
  void initState() {
    super.initState();

    Sighting? sighting = widget.sighting;

    title = "Add Sighting";

    if (sighting != null) {
      title = "Edit Sighting";
      sightVehicleValue.setStrValueByInt(sighting.vehicle_id!);
      sightVehicleDriverValue.setStrValueByInt(sighting.vehicle_driver_id!);
      sightBeaufortValue.setStrValueByInt(sighting.beaufort_wind!);
      sightDateValue.setDateTime(sighting.date!);
      sightTourStartValue.setTimeOfDy(sighting.tour_start!);
      sightTourEndValue.setTimeOfDy(sighting.tour_end!);
      sightDurationFromValue.setTimeOfDy(sighting.duration_from!);
      sightDurationUntilValue.setTimeOfDy(sighting.duration_until!);
      sightLocationBeginValue.setPositionStr(sighting.location_begin!);
      sightLocationEndValue.setPositionStr(sighting.location_end!);
      sightPhotoTakenValue.setIntValue(sighting.photo_taken!);
      sightDistanceCoastValue.setValue(sighting.distance_coast!);
      sightDistanceCoastEstimationGpsValue.setIntValue(sighting.distance_coast_estimation_gps!);
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

      sightDurationFromValue.setTimeof(TimeOfDay.now());

      if (_locationController.currentPosition != null) {
        sightLocationBeginValue.setPosition(_locationController.currentPosition!);

        var distance = UtilDistanceCoast.getDistance(_locationController.currentPosition!);
        sightDistanceCoastValue.setValue("$distance");
      }
    }
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

         sightDurationFrom = DynInput(
           context: context,
           title: "Sighting duration: from",
           hint: "",
           inputType: DynInputType.time,
           dynValue: sightDurationFromValue,
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

         sightDurationUntil = DynInput(
           context: context,
           title: "until",
           hint: "",
           inputType: DynInputType.time,
           dynValue: sightDurationUntilValue,
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

         sightLocationBegin = DynInput(
           context: context,
           title: "Position begin",
           hint: "",
           inputType: DynInputType.location,
           dynValue: sightLocationBeginValue,
           onChange: () {
             if (sightLocationBeginValue.posValue != null) {
               var distance = UtilDistanceCoast.getDistance(sightLocationBeginValue.posValue!);
               sightDistanceCoastValue.setValue("$distance");
             }
           },
         );

         sightLocationEnd = DynInput(
           context: context,
           title: "Position end",
           hint: "",
           inputType: DynInputType.location,
           dynValue: sightLocationEndValue,
         );

         sightPhotoTaken = DynInput(
           context: context,
           title: "Photos taken",
           hint: "",
           inputType: DynInputType.switcher,
           dynValue: sightPhotoTakenValue,
         );

         sightDistanceCoast = DynInput(
           context: context,
           title: "Distance to nearest coast (nm)",
           hint: "",
           inputType: DynInputType.numberdecimal,
           dynValue: sightDistanceCoastValue,
           onFormat: (value) {
             try {
               if (value != null) {
                 var fValue = double.parse(value.strValue);
                 fValue = 0.5399568035 * (fValue / 1000);

                 return "${fValue.toPrecision(2)}";
               }
             } catch(e) {
               if (kDebugMode) {
                 print(e);
               }
             }

             return "0.0";
           },
         );

         sightDistanceCoastEstimationGps = DynInput(
           context: context,
           title: "Estimation without GPS",
           hint: "",
           inputType: DynInputType.switcher,
           dynValue: sightDistanceCoastEstimationGpsValue,
         );

         sightSpecies = DynInput(
           context: context,
           title: "Species",
           hint: "",
           inputType: DynInputType.select,
           dynValue: sightSpeciesValue,
           selectList: _speciesController.speciesList.map((element) {
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

         sightSpeciesNum = DynInput(
           context: context,
           title: "Number of animals",
           hint: "",
           inputType: DynInputType.number,
           dynValue: sightSpeciesNumValue,
         );

         sightJuveniles = DynInput(
           context: context,
           title: 'Juveniles',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: sightJuvenilesValue,
         );

         sightCalves = DynInput(
           context: context,
           title: 'Calves',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: sightCalvesValue,
         );

         sightNewborns = DynInput(
           context: context,
           title: 'Newborns',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: sightNewbornsValue,
         );

         sightBehaviour = DynInput(
           context: context,
           title: 'Behaviour',
           hint: '',
           inputType: DynInputType.multiselect,
           dynValue: sightBehaviourValue,
           selectList: _behaviouralStateController.behaviouralStateList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList()
         );

         sightSubgroups = DynInput(
           context: context,
           title: 'Subgroups',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: sightSubgroupsValue,
         );

        sightGroupStructure = DynInput(
          context: context,
          title: 'Group Structure',
          hint: '',
          inputType: DynInputType.select,
          dynValue:sightGroupStructureValue,
          selectList: [
            DynInputSelectItem(value: "1", label: "widely dispersed"),
            DynInputSelectItem(value: "2", label: "dispersed"),
            DynInputSelectItem(value: "3", label: "loose"),
            DynInputSelectItem(value: "4", label: "tight"),
          ],
        );

         sightReaction = DynInput(
          context: context,
          title: 'Reaction',
          hint: '',
          inputType: DynInputType.select,
          dynValue: sightReactionValue,
          selectList: _encounterCategoriesController.encounterCategorieList.map((element) {
            return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
            );
          }).toList()
         );

        sightFreqBehaviour = DynInput(
          context: context,
          title: "Frequent behaviours of individuals",
          hint: "",
          inputType: DynInputType.tags,
          dynValue: sightFreqBehaviourValue,
          supportedTagList: const ['Test', 'SLP', 'SPY'],
        );

        sightRecAnimals = DynInput(
          context: context,
          title: "Recognizable animals",
          hint: "",
          inputType: DynInputType.textarea,
          dynValue: sightRecAnimalsValue,
        );

        sightOtherSpecies = DynInput(
          context: context,
          title: 'Other Species',
          hint: '',
          inputType: DynInputType.multiselect,
          selectList: _speciesController.speciesList.map((element) {
            var labelName = element.name!;

            if (element.name!.indexOf(',') > 0) {
              labelName = element.name!.split(",")[0];
            }

            return DynInputSelectItem(
                value: element.id!.toString(),
                label: labelName
            );
          }).toList(),
          dynValue: sightOtherSpeciesValue,
        );

        sightOther = DynInput(
          context: context,
          title: "Other",
          hint: "",
          inputType: DynInputType.textarea,
          dynValue: sightOtherValue,
        );

        sightOtherVehicle = DynInput(
          context: context,
          title: "Other boats present",
          hint: "",
          inputType: DynInputType.textarea,
          dynValue: sightOtherVehicleValue,
        );

        sightNote = DynInput(
          context: context,
          title: "Note",
          hint: "",
          inputType: DynInputType.textarea,
          dynValue: sightNoteValue,
        );

        sightImage = DynInput(
          context: context,
          title: "Picture",
          hint: "",
          inputType: DynInputType.image,
          dynValue: sightImageValue,
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
                         title,
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
                       Row(
                         children: [
                           Expanded(
                               child: sightDurationFrom
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                               child: sightDurationUntil
                           )
                         ],
                       ),
                       sightLocationBegin,
                       sightLocationEnd,
                       sightDistanceCoast,
                       Row(
                         children: [
                           Expanded(
                               child: sightPhotoTaken
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                               child: sightDistanceCoastEstimationGps
                           )
                         ],
                       ),
                       sightSpecies,
                       sightSpeciesNum,
                       Row(
                         children: [
                           Expanded(
                               child: sightJuveniles
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                               child: sightCalves
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                               child: sightNewborns
                           ),
                         ],
                       ),
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
                       const SizedBox(height: 30),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Container(),
                           DefaultButton(
                             buttonIcon: Icons.save_alt,
                             label: "Save Sighting",
                             onTab: () {
                               _saveSightingToDb();
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
