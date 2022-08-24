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
  DateTime _selectedDate = DateTime.now();

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
              DynInput(
                context: context,
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                inputType: DynInputType.date,
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
