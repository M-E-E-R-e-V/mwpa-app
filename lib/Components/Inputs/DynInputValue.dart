import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Util/AppLog.dart';

/// One entry of a SelectInput / MultiSelectInput.
class DynInputSelectItem {
  String value = "";
  String label = "";

  /// marked as deleted on the server: only shown when it is the current
  /// value (old sightings keep their entry), never selectable again
  final bool deleted;

  DynInputSelectItem({required this.value, required this.label, this.deleted = false});

  /// withDeleted - select items of the [active] entries plus the [deleted]
  /// ones (marked, see [deleted]), both built by [toItem]
  static List<DynInputSelectItem> withDeleted<T>(
      List<T> active, List<T> deleted, DynInputSelectItem Function(T element) toItem) {
    return [
      ...active.map(toItem),
      ...deleted.map(toItem).map(
          (item) => DynInputSelectItem(value: item.value, label: item.label, deleted: true)),
    ];
  }
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
    // nothing entered / selected yet
    if (strValue.trim().isEmpty) {
      return 0;
    }

    try {
      return int.parse(strValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch(e) {
      AppLog.w('Input', 'getStrValueAsInt: $strValue', e);
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
      AppLog.w('Input', 'setDateTime: $date', e);
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
      AppLog.w('Input', 'setTimeOfDy: $time', e);
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
      AppLog.w('Input', 'setPositionStr: $pos', e);
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
      AppLog.w('Input', 'setMultiValue: $val', e);
    }
  }

  String getImagePath() {
    return imgPath;
  }

  void setImagePath(String imagePath) {
    imgPath = imagePath;
  }
}
