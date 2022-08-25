import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Pages/List/DynInput.dart';

class EditSightingPage extends StatefulWidget {
  const EditSightingPage({Key? key}) : super(key: key);

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

class _EditSightingPageState extends State<EditSightingPage> {
  String title = "Add Sighting";
  late DynInput sightFrom;
  late DynInput sightDate;
  late DynInput sightTourStart;
  late DynInput sightTourEnd;

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
    sightFrom = DynInput(
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
              sightFrom,
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
              DynInput(
                context: context,
                title: "Number of animals",
                hint: "1",
                inputType: DynInputType.text,
              )
            ],
          ),
        ),
      ),
    );
  }
}
