import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DynInput.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Models/Sighting.dart';

class EditSightingPage extends StatefulWidget {
  const EditSightingPage({Key? key}) : super(key: key);

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

class _EditSightingPageState extends State<EditSightingPage> {
  final SightingController _sightingController = Get.find<SightingController>();
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final VehicleDriverController _vehicleDriverController = Get.find<VehicleDriverController>();
  final SpeciesController _speciesController = Get.find<SpeciesController>();

  String title = "Add Sighting";

  late DynInput sightVehicle;
  late DynInput sightDate;
  late DynInput sightVehicleDriver;
  late DynInput sightTourStart;
  late DynInput sightTourEnd;

  late DynInput sightDurationFrom;
  late DynInput sightDurationUntil;

  late DynInput sightLocationBegin;
  late DynInput sightLocationEnd;

  late DynInput sightPhotoTaken;
  late DynInput sightDistanceCoast;
  late DynInput sightDistanceCoastEstimationGps;

  late DynInput sightSpecies;
  late DynInput sightSpeciesNum;

  late DynInput sightJuveniles;
  late DynInput sightCalves;
  late DynInput sightNewborns;

  late DynInput sightBehaviour;
  late DynInput sightSubgroups;
  late DynInput sightReaction;

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

  _addSightingToDb() async {
    await _sightingController.addSighting(
      newSighting: Sighting(
        unid: "",
        vehicle_id: sightVehicle.dynValue?.getStrValueAsInt(),
        vehicle_driver_id: sightVehicleDriver.dynValue?.getStrValueAsInt(),
        date: sightDate.dynValue?.getDateTime(),
        species_id: sightSpecies.dynValue?.getStrValueAsInt()
      )
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        sightVehicle = DynInput(
           context: context,
           title: "Sighting from",
           hint: "",
           inputType: DynInputType.select,
           dynValue: DynInputValue(),
           selectList: _vehicleController.vehicleList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList(),
         );

         sightDate = DynInput(
           context: context,
           title: "Date",
           hint: "",
           inputType: DynInputType.date,
           dynValue: DynInputValue(),
         );

         sightVehicleDriver = DynInput(
           context: context,
           title: "Skipper",
           hint: "",
           inputType: DynInputType.select,
           dynValue: DynInputValue(),
           selectList: _vehicleDriverController.vehicleDriverList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.username!
             );
           }).toList(),
         );

         sightTourStart = DynInput(
           context: context,
           title: "Start of trip",
           hint: "",
           inputType: DynInputType.time,
           dynValue: DynInputValue(),
         );

         sightTourEnd = DynInput(
           context: context,
           title: "End of trip",
           hint: "",
           inputType: DynInputType.time,
           dynValue: DynInputValue(),
         );

         sightDurationFrom = DynInput(
           context: context,
           title: "Sighting duration from",
           hint: "",
           inputType: DynInputType.time,
           dynValue: DynInputValue(),
         );

         sightDurationUntil = DynInput(
           context: context,
           title: "Sighting duration until",
           hint: "",
           inputType: DynInputType.time,
           dynValue: DynInputValue(),
         );

         sightLocationBegin = DynInput(
           context: context,
           title: "Position begin",
           hint: "",
           inputType: DynInputType.location,
           dynValue: DynInputValue(),
         );

         sightLocationEnd = DynInput(
           context: context,
           title: "Position end",
           hint: "",
           inputType: DynInputType.location,
           dynValue: DynInputValue(),
         );

         sightPhotoTaken = DynInput(
           context: context,
           title: "Photos taken",
           hint: "",
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightDistanceCoast = DynInput(
           context: context,
           title: "Distance to nearest coast",
           hint: "",
           inputType: DynInputType.numberdecimal,
           dynValue: DynInputValue(),
         );

         sightDistanceCoastEstimationGps = DynInput(
           context: context,
           title: "Estimation without GPS",
           hint: "",
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightSpecies = DynInput(
           context: context,
           title: "Species",
           hint: "",
           inputType: DynInputType.select,
           dynValue: DynInputValue(),
           selectList: _speciesController.speciesList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList(),
         );

         sightSpeciesNum = DynInput(
           context: context,
           title: "Number of animals",
           hint: "",
           inputType: DynInputType.number,
           dynValue: DynInputValue(),
         );

         sightJuveniles = DynInput(
           context: context,
           title: 'Juveniles',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightCalves = DynInput(
           context: context,
           title: 'Calves',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightNewborns = DynInput(
           context: context,
           title: 'Newborns',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightBehaviour = DynInput(
           context: context,
           title: 'Behaviour',
           hint: '',
           inputType: DynInputType.select,
           dynValue: DynInputValue(),
         );

         sightSubgroups = DynInput(
           context: context,
           title: 'Subgroups',
           hint: '',
           inputType: DynInputType.switcher,
           dynValue: DynInputValue(),
         );

         sightReaction = DynInput(
           context: context,
           title: 'Reaction',
           hint: '',
           inputType: DynInputType.select,
           dynValue: DynInputValue(),
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
                     const SizedBox(height: 18),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(),
                         DefaultButton(
                             label: "+ Add Sighting",
                             onTab: () {
                               _addSightingToDb();
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
