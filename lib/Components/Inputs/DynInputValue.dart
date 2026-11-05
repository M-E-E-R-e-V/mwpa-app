import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// One entry of a SelectInput / MultiSelectInput.
class DynInputSelectItem {
  String value = "";
  String label = "";

  DynInputSelectItem({required this.value, required this.label});
}

/// DynInputValue - mutable value holder shared by the page and its input
/// widget. It carries one slot per input kind (string, date, time, int,
/// position, multi, image); each input uses only the slot of its kind.
class DynInputValue {
  String strValue = "";
  DateTime dateValue = DateTime.now();
  TimeOfDay? timeValue;
  int intValue = 0;
  Position? posValue;
  List<DynInputValue> multiValue = [];
  String imgPath = "";

  void setValue(String newValue) {
    strValue = newValue;
  }

  String getValue() {
    return strValue;
  }

  int getStrValueAsInt() {
    try {
      return int.parse(strValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch(e) {
      if (kDebugMode) {
        print('DynInputValue::getStrValueAsInt: $strValue');
        print(e);
      }
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
      dateValue = DateTime.parse(date).toLocal();
    } catch(e) {
      if (kDebugMode) {
        print('DynInputValue::setDateTime: $date');
        print(e);
      }
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
      if (kDebugMode) {
        print('DynInputValue::setTimeOfDy: $time');
        print(e);
      }
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
      if (kDebugMode) {
        print('DynInputValue::setPositionStr: $pos');
        print(e);
      }
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

    for (var element in multiValue) {
      data["$index"] = element.strValue;
      index++;
    }

    return const JsonEncoder().convert(data);
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
      if (kDebugMode) {
        print('DynInputValue::setMultiValue: $val');
        print(e);
      }
    }
  }

  String getImagePath() {
    return imgPath;
  }

  void setImagePath(String imagePath) {
    imgPath = imagePath;
  }
}
