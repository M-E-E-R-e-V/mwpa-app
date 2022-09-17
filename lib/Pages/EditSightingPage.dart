import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DynInput.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';

class EditSightingPage extends StatefulWidget {
  final Sighting? sighting;

  const EditSightingPage({Key? key, this.sighting}) : super(key: key);

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

class _EditSightingPageState extends State<EditSightingPage> {
  final LocationController _locationController = Get.find<LocationController>();
  final SightingController _sightingController = Get.find<SightingController>();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final VehicleDriverController _vehicleDriverController = Get.find<VehicleDriverController>();
  final SpeciesController _speciesController = Get.find<SpeciesController>();
  final EncounterCategoriesController _encounterCategoriesController = Get.find<EncounterCategoriesController>();
  final BehaviouralStateController _behaviouralStateController = Get.find<BehaviouralStateController>();

  String title = "";
  bool isInit = false;

  late DynInput sightVehicle;
  DynInputValue sightVehicleValue = DynInputValue();

  late DynInput sightVehicleDriver;
  DynInputValue sightVehicleDriverValue = DynInputValue();

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

  _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryHeaderColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: kButtonFontColor,
        ),
        onPressed: () async {
          //await Navigator.pushNamed(context, '/List');
          Get.back();
        },
      ),
    );
  }

  _saveSightingToDb() async {
    Sighting tsigh = Sighting(
        unid: "",
        vehicle_id: sightVehicle.dynValue?.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriver.dynValue
            ?.getStrValueAsInt(),
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
        reaction_id: sightReaction.dynValue?.getStrValueAsInt(),
        freq_behaviour: sightFreqBehaviour.dynValue?.getValue(),
        recognizable_animals: sightRecAnimals.dynValue?.getValue(),
        other_species: sightOtherSpecies.dynValue?.getMultiValue(),
        other: sightOther.dynValue?.getValue(),
        other_vehicle: sightOtherVehicle.dynValue?.getValue(),
        note: sightNote.dynValue?.getValue()
    );

    if (widget.sighting != null) {
      tsigh.id = widget.sighting?.id!;

      var result = await _sightingController.updateSighting(tSighting: tsigh);
      print(result);
    } else {
      await _sightingController.addSighting(newSighting: tsigh);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    Sighting? sighting = widget.sighting;

    if (!isInit) {
      title = "Add Sighting";

      if (sighting != null) {
        title = "Edit Sighting";
        sightVehicleValue.setStrValueByInt(sighting.vehicle_id!);
        sightVehicleDriverValue.setStrValueByInt(sighting.vehicle_driver_id!);
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
        sightReactionValue.setStrValueByInt(sighting.reaction_id!);
        sightFreqBehaviourValue.setValue(sighting.freq_behaviour!);
        sightRecAnimalsValue.setValue(sighting.recognizable_animals!);
        sightOtherSpeciesValue.setMultiValue(sighting.other_species!);
        sightOtherValue.setValue(sighting.other!);
        sightOtherVehicleValue.setValue(sighting.other_vehicle!);
        sightNoteValue.setValue(sighting.note!);
      } else {
        sightDurationFromValue.setTimeof(TimeOfDay.now());

        if (_locationController.currentPosition != null) {
          sightLocationBeginValue.setPosition(_locationController.currentPosition!);

          var distance = UtilDistanceCoast.getDistance(_locationController.currentPosition!);
          sightDistanceCoastValue.setValue("$distance");
        }
      }

      isInit = true;
    }

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
         );

         sightDurationUntil = DynInput(
           context: context,
           title: "until",
           hint: "",
           inputType: DynInputType.time,
           dynValue: sightDurationUntilValue,
         );

         sightLocationBegin = DynInput(
           context: context,
           title: "Position begin",
           hint: "",
           inputType: DynInputType.location,
           dynValue: sightLocationBeginValue,
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
           title: "Distance to nearest coast (m)",
           hint: "",
           inputType: DynInputType.numberdecimal,
           dynValue: sightDistanceCoastValue,
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
          inputType: DynInputType.textarea,
          dynValue: sightFreqBehaviourValue,
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

         return Scaffold(
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
                     sightReaction,
                     sightFreqBehaviour,
                     sightRecAnimals,
                     sightOtherSpecies,
                     sightOther,
                     sightOtherVehicle,
                     sightNote,
                     const SizedBox(height: 18),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(),
                         DefaultButton(
                             label: sighting != null ? "Update Sighting" : "Add Sighting",
                             onTab: () {
                               _saveSightingToDb();
                             }
                         ),
                       ],
                     ),
                     const SizedBox(height: 18),
                   ]
               ),
             ),
           ),
         );
     });
  }
}
