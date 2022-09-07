import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DynInput.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
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

  String title = "Add Sighting";

  late DynInput sightVehicle;
  late DynInput sightDate;
  late DynInput sightVehicleDriver;
  late DynInput sightTourStart;
  late DynInput sightTourEnd;

  late DynInput sightDurationFrom;
  late DynInput sightDurationUntil;

  late DynInput sightBeginLoc;
  late DynInput sightEndLoc;

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
          await Navigator.pushNamed(context, '/List');
        },
      ),
    );
  }

  _addSightingToDb() {
    /*_sightingController.addSighting(
      sighting: Sighting(
        uid: "uid"
      )
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        sightVehicle = DynInput(
           context: context,
           title: "Sighting from",
           hint: "",
           inputType: DynInputType.select,
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
         );

         sightVehicleDriver = DynInput(
           context: context,
           title: "Skipper",
           hint: "",
           inputType: DynInputType.select,
           selectList: _vehicleDriverController.vehicleDriverList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.description!
             );
           }).toList(),
         );

         sightTourStart = DynInput(
             context: context,
             title: "Start of trip",
             hint: "",
             inputType: DynInputType.time
         );

         sightTourEnd = DynInput(
             context: context,
             title: "End of trip",
             hint: "",
             inputType: DynInputType.time
         );

         sightDurationFrom = DynInput(
             context: context,
             title: "Sighting duration from",
             hint: "",
             inputType: DynInputType.time
         );

         sightDurationUntil = DynInput(
             context: context,
             title: "Sighting duration until",
             hint: "",
             inputType: DynInputType.time
         );

         sightBeginLoc = DynInput(
             context: context,
             title: "Position begin",
             hint: "",
             inputType: DynInputType.location
         );

         sightEndLoc = DynInput(
             context: context,
             title: "Position end",
             hint: "",
             inputType: DynInputType.location
         );

         sightPhotoTaken = DynInput(
             context: context,
             title: "Photos taken",
             hint: "",
             inputType: DynInputType.switcher
         );

         sightDistanceCoast = DynInput(
             context: context,
             title: "Distance to nearest coast",
             hint: "",
             inputType: DynInputType.numberdecimal
         );

         sightDistanceCoastEstimationGps = DynInput(
             context: context,
             title: "Estimation without GPS",
             hint: "",
             inputType: DynInputType.switcher
         );

         sightSpecies = DynInput(
             context: context,
             title: "Species",
             hint: "",
             inputType: DynInputType.select
         );

         sightSpeciesNum = DynInput(
           context: context,
           title: "Number of animals",
           hint: "",
           inputType: DynInputType.number,
         );

         sightJuveniles = DynInput(
             context: context,
             title: 'Juveniles',
             hint: '',
             inputType: DynInputType.switcher
         );

         sightCalves = DynInput(
             context: context,
             title: 'Calves',
             hint: '',
             inputType: DynInputType.switcher
         );

         sightNewborns = DynInput(
             context: context,
             title: 'Newborns',
             hint: '',
             inputType: DynInputType.switcher
         );

         sightBehaviour = DynInput(
             context: context,
             title: 'Behaviour',
             hint: '',
             inputType: DynInputType.select
         );

         sightSubgroups = DynInput(
             context: context,
             title: 'Subgroups',
             hint: '',
             inputType: DynInputType.switcher
         );

         sightReaction = DynInput(
             context: context,
             title: 'Reaction',
             hint: '',
             inputType: DynInputType.select
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
                     Row(
                       children: [
                         Expanded(
                             child: sightVehicle
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                             child: sightVehicleDriver
                         )
                       ],
                     ),
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
                     sightBeginLoc,
                     sightEndLoc,
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
                     Row(
                       children: [
                         Expanded(
                             child: sightSpecies
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                             child: sightSpeciesNum
                         )
                       ],
                     ),
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
