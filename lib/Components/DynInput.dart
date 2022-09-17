import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import '../Location/LocationProvider.dart';

enum DynInputType {
  text,
  textarea,
  number,
  numberdecimal,
  date,
  time,
  select,
  switcher,
  location,
  multiselect,
}

class DynInputSelectItem {
  String value = "";
  String label = "";

  DynInputSelectItem({required this.value, required this.label});
}

class DynInputValue {
  String strValue = "";
  DateTime dateValue = DateTime.now();
  TimeOfDay? timeValue;
  int intValue = 0;
  Position? posValue;
  List<DynInputValue> multiValue = [];

  setValue(String newValue) {
    strValue = newValue;
  }

  String getValue() {
    return strValue;
  }

  int getStrValueAsInt() {
    try {
      return int.parse(strValue);
    } catch(e) {
      print(e);
    }

    return 0;
  }

  void setStrValueByInt(int val) {
    strValue = "$val";
  }

  String getDateTime() {
    return dateValue.toUtc().toString();
  }

  void setDateTime(String date) {
    try {
      dateValue = DateTime.parse(date);
    } catch(e) {
      print(e);
    }
  }

  String getTimeOfDay() {
    if (timeValue == null) {
      return "";
    }

    var hour = "${timeValue!.hour}";
    var min = "${timeValue!.minute}";

    if (timeValue!.hour < 10) {
      hour = "0${timeValue!.hour}";
    }

    if (timeValue!.minute < 10) {
      min = "0${timeValue!.minute}";
    }

    return "$hour:$min";
  }

  void setTimeOfDy(String time) {
    try {
      var parts = time.split(":");

      timeValue =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    catch(e) {
      print(e);
    }
  }

  void setTimeof(TimeOfDay atime) {
    timeValue = atime;
  }

  String getPosition() {
    return jsonEncode(posValue?.toJson());
  }

  void setPositionStr(String pos) {
    try {
      posValue = Position.fromMap(jsonDecode(pos));
    } catch(e) {
      print(e);
    }
  }

  void setPosition(Position pos) {
    posValue = pos;
  }

  int getIntValue() {
    return intValue;
  }

  void setIntValue(int val) {
    intValue = val;
  }

  String getMultiValue() {
    Map<String, dynamic> data = {};

    var index = 0;

    multiValue.forEach((element) {
      data["$index"] = element.strValue;
      index++;
    });

    return JsonEncoder().convert(data);
  }

  void setMultiValue(String val) {
    try {
      Map<String, dynamic> data = jsonDecode(val);

      data.forEach((key, value) {
        DynInputValue tval = DynInputValue();
        tval.setValue(value);

        multiValue.add(tval);
      });
    } catch(e) {
      print(e);
    }
  }
}

class DynInput extends StatefulWidget {
  final BuildContext context;
  final String? title;
  final String hint;
  final DynInputType inputType;
  final Widget? widget;
  final List<DynInputSelectItem>? selectList;
  final DynInputValue? dynValue;

  const DynInput({
    Key? key,
    required this.context,
    required this.hint,
    required this.inputType,
    this.title,
    this.widget,
    this.selectList,
    this.dynValue
  }) : super(key: key);

  @override
  State<DynInput> createState() => _DynInputState();
}

class _DynInputState extends State<DynInput> {
  String title = "";
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
    var initialTime = TimeOfDay.now();

    if (dynValue!.timeValue != null) {
      initialTime = dynValue!.timeValue!;
    }

    var picketTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: initialTime
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

  Widget buildSingle(BuildContext context) {
    Widget? mainWidget;
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
          if (dynValue!.timeValue != null) {
            tHint = dynValue!.timeValue!.format(context);
          }
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
          isExpanded: true,
          style: subTitleStyle,
          itemHeight: null,
          underline: Container(
            height: 0,
          ),
          items: selectList.map<DropdownMenuItem<String>>((DynInputSelectItem value) {
            return DropdownMenuItem<String>(
              value: value.value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(value.label),
              ),
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
            var element = selectList.elementAt(selectIndex);

            tHint = element.label;
          } else {
            if (dynValue!.strValue != "" && dynValue!.strValue != "0") {
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
                value: dynValue!.intValue >= 1,
                size: SwitcherSize.large,
                switcherButtonRadius: 50,
                enabledSwitcherButtonRotate: true,
                iconOff: Icons.radio_button_unchecked,
                iconOn: Icons.radio_button_checked,
                colorOff: kPrimaryColor,
                colorOn: kButtonBackgroundColor,
                onChanged: (bool state) {
                  if (state) {
                    dynValue!.intValue = 1;
                  } else {
                    dynValue!.intValue = 0;
                  }
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
            title += " (accuracy: ${dynValue!.posValue!.accuracy.toInt().toString()} m)";

            tHint = UtilPosition.getStr(dynValue!.posValue!);
          }
        }
        break;

      case DynInputType.number:
        textInputType = TextInputType.number;

        if (tHint == "") {
          tHint = dynValue!.strValue;
        }
        break;

      case DynInputType.numberdecimal:
        textInputType = const TextInputType.numberWithOptions(decimal: true);

        if (tHint == "") {
          tHint = dynValue!.strValue;
        }
        break;

      case DynInputType.textarea:
        textInputType = TextInputType.multiline;

        if (tHint == "") {
          tHint = dynValue!.strValue;
        }
        break;

      default:
        if (tHint == "") {
          tHint = dynValue!.strValue;
        }
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
              flex: 3,
              child: TextFormField(
                readOnly: tWidget == null ? false : true,
                autofocus: false,
                cursorColor: Colors.grey[700],
                onChanged: (text) {
                  setState(() {
                    dynValue?.strValue = text;
                  });
                },
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
          Expanded(
            child: tWidget == null ? Container() : Container(
              alignment: AlignmentDirectional.topEnd,
              child: Align(
                alignment: Alignment.topRight,
                child: tWidget
              ),
            )
          )
        ],
      ),
    );

    return mainWidget;
  }

  Widget buildMultiSelect(BuildContext context) {
    List<Widget> children = [];

    dynValue = widget.dynValue;
    dynValue ??= DynInputValue();

    if (dynValue!.multiValue.isEmpty) {
      dynValue!.multiValue.add(DynInputValue());
    }

    children.addAll(dynValue!.multiValue.map((e) => DynInput(
        context: context,
        hint: "",
        inputType: DynInputType.select,
        dynValue: e,
        selectList: widget.selectList
    )));

    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            )
          ),
          Expanded(
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.only(left: 14),
              child: DefaultButton(
                label: '+',
                width: 50,
                onTab: () {
                  setState(() {
                    dynValue!.multiValue.add(DynInputValue());
                  });
                },
              )
            )
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    
    if (widget.title != null) {
      title = widget.title!;
    }

    switch (widget.inputType) {
      case DynInputType.multiselect:
        children.add(buildMultiSelect(context));
        break;

      default:
        children.add(buildSingle(context));
    }

    if (widget.title != null) {
      children = [
        Text(
          title,
          style: titleStyle,
        ),
        ...children,
      ];
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
