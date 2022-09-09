import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import '../Location/LocationProvider.dart';

enum DynInputType {
  text,
  number,
  numberdecimal,
  date,
  time,
  select,
  switcher,
  location
}

class DynInputSelectItem {
  String value = "";
  String label = "";

  DynInputSelectItem({required this.value, required this.label});
}

class DynInputValue {
  String strValue = "";
  DateTime dateValue = DateTime.now();
  TimeOfDay timeValue = TimeOfDay.now();
  int intValue = 0;
  Position? posValue;

  setValue(String newValue) {
    strValue = newValue;
  }

  String getValue() {
    return strValue;
  }

  int getStrValueAsInt() {
    return int.parse(strValue);
  }

  String getDateTime() {
    return dateValue.toUtc().toString();
  }
}

class DynInput extends StatefulWidget {
  final BuildContext context;
  final String title;
  final String hint;
  final DynInputType inputType;
  final TextEditingController? controller;
  final Widget? widget;
  final List<DynInputSelectItem>? selectList;
  final DynInputValue? dynValue;

  const DynInput({
    Key? key,
    required this.context,
    required this.title,
    required this.hint,
    required this.inputType,
    this.controller,
    this.widget,
    this.selectList,
    this.dynValue
  }) : super(key: key);

  @override
  State<DynInput> createState() => _DynInputState();
}

class _DynInputState extends State<DynInput> {
  DynInputValue? dynValue;

  _getDateFromUser() async {
    DateTime? pickDate = await showDatePicker(
      context: widget.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2040)
    );

    if (pickDate != null) {
      setState(() {
        dynValue!.dateValue = pickDate;
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
        dynValue!.timeValue = picketTime;
      });
    }
  }

  _getLocationFromUser() async {
    var position = await LocationProvider.getLocation();

    setState(() {
      dynValue!.posValue = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? mainWidget;
    var ttitle = widget.title;
    var tWidget = widget.widget;
    var tHint = widget.hint;
    var textInputType = TextInputType.text;
    dynValue = widget.dynValue;

    dynValue ??= DynInputValue();

    switch (widget.inputType) {
      case DynInputType.date:
        tWidget = IconButton(
          icon: Icon(
            Icons.calendar_today_outlined,
            color: Get.isDarkMode ? kPrimaryDarkFontColor :  kPrimaryFontColor,
          ),
          onPressed: () {
            _getDateFromUser();
          },
        );

        if (tHint == "") {
          tHint = DateFormat.yMd().format(dynValue!.dateValue);
        }
        break;

      case DynInputType.time:
        tWidget = IconButton(
          icon: Icon(
            Icons.access_time_rounded,
            color: Get.isDarkMode ? kPrimaryDarkFontColor :  kPrimaryFontColor,
          ),
          onPressed: () {
            _getTimeFromUser();
          }
        );

        if (tHint == "") {
          tHint = dynValue!.timeValue.format(context);
        }
        break;

      case DynInputType.select:
        List<DynInputSelectItem> selectList = [];

        if (widget.selectList != null) {
          selectList = widget.selectList!;
        }

        tWidget = DropdownButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Get.isDarkMode ? kPrimaryDarkFontColor :  kPrimaryFontColor,
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
                dynValue!.strValue = value;
              }
            });
          },
        );

        if (tHint == "") {
          var selectIndex = selectList.indexWhere((element) {
            if (element.value == dynValue!.strValue) {
              return true;
            }

            return false;
          });

          if (selectIndex >= 0) {
            tHint = selectList.elementAt(selectIndex).label;
          } else {
            if (dynValue!.strValue != "") {
              tHint = "unknown by id: ${dynValue!.strValue}";
            } else {
              tHint = "<please select>";
            }
          }

          if (selectList.isEmpty) {
            tHint = "<empty list>";
          }
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
            iconOff: Icons.radio_button_unchecked,
            iconOn: Icons.radio_button_checked,
            colorOff: kPrimaryColor,
            colorOn: kButtonBackgroundColor,
            onChanged: (bool state) {

            })
        );
        break;

      case DynInputType.location:
        tWidget = IconButton(
            icon: Icon(
              Icons.edit_location,
              color: Get.isDarkMode ? kPrimaryDarkFontColor :  kPrimaryFontColor,
            ),
            onPressed: () async {
              _getLocationFromUser();
            }
        );


        if (dynValue!.posValue != null) {
          if (tHint == "") {
            LatLongConverter converter = LatLongConverter();
            var latDms = converter.getDegreeFromDecimal(dynValue!.posValue!.latitude);
            var longDms = converter.getDegreeFromDecimal(dynValue!.posValue!.longitude);

            var keyLong = "E";
            var keyLat = "N";

            if (longDms[0] < 0) {
              keyLong = "W";
            }

            if (latDms[0] < 0) {
              keyLat = "S";
            }

            ttitle += " (accuracy: ${dynValue!.posValue!.accuracy.toInt().toString()} m)";

            tHint = "$keyLat: ${latDms[0]}° ${latDms[1]}' ${latDms[2]}\" - $keyLong: ${longDms[0]}° ${longDms[1]}' ${longDms[2]}\" ";
          }
        }
        break;

      case DynInputType.number:
        textInputType = TextInputType.number;
        break;

      case DynInputType.numberdecimal:
        textInputType = const TextInputType.numberWithOptions(decimal: true);
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
                  keyboardType: textInputType,
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
            ttitle,
            style: titleStyle,
          ),
          mainWidget
        ],
      ),
    );
  }
}
