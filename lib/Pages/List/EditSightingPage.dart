import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Pages/List/DynInput.dart';

class EditSightingPage extends StatefulWidget {
  const EditSightingPage({Key? key}) : super(key: key);

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

class _EditSightingPageState extends State<EditSightingPage> {
  String title = "Add Sighting";
  late DynInput sightVehicle;
  late DynInput sightDate;
  late DynInput sightVehicleDriver;
  late DynInput sightTourStart;
  late DynInput sightTourEnd;

  late DynInput sightSpecies;
  late DynInput sightSpeciesNum;

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

  @override
  Widget build(BuildContext context) {
    sightVehicle = DynInput(
      context: context,
      title: "Sighting from",
      hint: "",
      inputType: DynInputType.select,
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
      inputType: DynInputType.select
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
      inputType: DynInputType.text,
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
                    child: sightSpecies
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: sightSpeciesNum
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
