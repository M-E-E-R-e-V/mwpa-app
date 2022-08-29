import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';

enum DynInputType {
  text,
  date,
  time,
  select,
  switcher,
}

class DynInputSelectItem {
  String value = "";
  String label = "";

  DynInputSelectItem({required this.value, required this.label});
}

class DynInput extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String hint;
  final DynInputType inputType;
  final TextEditingController? controller;
  final Widget? widget;

  const DynInput({
    Key? key,
    required this.context,
    required this.title,
    required this.hint,
    required this.inputType,
    this.controller,
    this.widget
  }) : super(key: key);

  @override
  State<DynInput> createState() => _DynInputState();
}

class _DynInputState extends State<DynInput> {
  String strValue = "";
  DateTime dateValue = DateTime.now();
  TimeOfDay timeValue = TimeOfDay.now();
  int intValue = 0;
  List<DynInputSelectItem> selectList = [];

  _getDateFromUser() async {
    DateTime? pickDate = await showDatePicker(
      context: widget.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2040)
    );

    if (pickDate != null) {
      setState(() {
        dateValue = pickDate;
      });
    }
  }

  _getTimeFromUser() async {
    var picketTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: const TimeOfDay(
        hour: 9,
        minute: 10
      )
    );

    if (picketTime != null) {
      setState(() {
        timeValue = picketTime;
      });
    }
  }

  setSelectList(List<DynInputSelectItem> list) {
    selectList = list;
  }

  @override
  Widget build(BuildContext context) {
    Widget? mainWidget;
    var tWidget = widget.widget;
    var tHint = widget.hint;

    switch (widget.inputType) {
      case DynInputType.date:
        tWidget = IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: kPrimaryFontColor,
          ),
          onPressed: () {
            _getDateFromUser();
          },
        );

        if (tHint == "") {
          tHint = DateFormat.yMd().format(dateValue);
        }
        break;

      case DynInputType.time:
        tWidget = IconButton(
          icon: const Icon(
            Icons.access_time_rounded,
            color: kPrimaryFontColor,
          ),
          onPressed: () {
            _getTimeFromUser();
          }
        );

        if (tHint == "") {
          tHint = timeValue.format(context);
        }
        break;

      case DynInputType.select:
        tWidget = DropdownButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: kPrimaryFontColor,
          ),
          iconSize: 32,
          elevation: 0,
          style: subTitleStyle,
          underline: Container(
            height: 0,
          ),
          items: selectList.map<DropdownMenuItem<String>>((DynInputSelectItem value) {
            return DropdownMenuItem<String>(
              value: value.value,
              child: Text(value.label),
            );
          }
          ).toList(),
          onChanged: (String? value) {
            setState(() {
              if (value != null) {
                strValue = value;
              }
            });
          },
        );

        if (tHint == "") {
          tHint = strValue;
        }
        break;

      case DynInputType.switcher:
        mainWidget = Container(
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.only(left: 14),
          child: Switcher(
            value: false,
            size: SwitcherSize.large,
            switcherButtonRadius: 50,
            enabledSwitcherButtonRotate: true,
            iconOff: Icons.lock,
            iconOn: Icons.lock_open,
            colorOff: kPrimaryColor,
            colorOn: kButtonBackgroundColor,
            onChanged: (bool state) {

            })
        );
        break;
    }

    mainWidget ??= Container(
        height: 52,
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
            border: Border.all(
                color: kPrimaryColor,
                width: 1.0
            ),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            Expanded(
                child: TextFormField(
                  readOnly: tWidget == null ? false : true,
                  autofocus: false,
                  cursorColor: Colors.grey[700],
                  controller: widget.controller,
                  style: subTitleStyle,
                  decoration: InputDecoration(
                      hintText: tHint,
                      hintStyle: subTitleStyle,
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.redAccent.withOpacity(0.0),
                              width: 0
                          )
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.redAccent.withOpacity(0.0),
                              width: 0
                          )
                      )
                  ),
                )
            ),
            tWidget == null ? Container() : Container(
              child: tWidget,
            )
          ],
        ),
      );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: titleStyle,
          ),
          mainWidget
        ],
      ),
    );
  }
}
