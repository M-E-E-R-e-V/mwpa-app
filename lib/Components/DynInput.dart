import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import 'package:textfield_tags/textfield_tags.dart';

enum DynInputType {
  text,
  textarea,
  number,
  numberdecimal,
  numberchars,
  date,
  time,
  select,
  switcher,
  nyntogglebtn,
  location,
  multiselect,
  multiselectmixed,
  tags,
  image
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
  String imgPath = "";

  setValue(String newValue) {
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

class DynInput extends StatefulWidget {
  final BuildContext context;
  final String? title;
  final String hint;
  final DynInputType inputType;
  final Widget? widget;
  final List<DynInputSelectItem>? selectList;
  final DynInputValue? dynValue;
  final Function? onChange;
  final Function(DynInputValue?)? onFormat;
  final List<String>? supportedTagList;

  const DynInput({
    Key? key,
    required this.context,
    required this.hint,
    required this.inputType,
    this.title,
    this.widget,
    this.selectList,
    this.dynValue,
    this.onChange,
    this.onFormat,
    this.supportedTagList
  }) : super(key: key);

  @override
  State<DynInput> createState() => _DynInputState();
}

class _DynInputState extends State<DynInput> {
  final LocationController _locationController = Get.find<LocationController>();
  TextfieldTagsController? _tagController;

  File? _image;
  ImagePicker? picker;
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

      if (widget.onChange != null) {
        widget.onChange!();
      }
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

      if (widget.onChange != null) {
        widget.onChange!();
      }
    }
  }

  _getLocationFromUser() async {
    var position = _locationController.currentPosition!;

    setState(() {
      dynValue!.posValue = position;
    });

    if (widget.onChange != null) {
      widget.onChange!();
    }
  }

  _getImage(ImageSource imageSource) async {
    XFile? imageFile = await picker!.pickImage(source: imageSource);
    //if user doesn't take any image, just return.
    if (imageFile == null) return;

    setState(() {
        _image = File(imageFile.path);

        if (_image != null) {
          dynValue!.imgPath = _image!.path;
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    dynValue = widget.dynValue;
    dynValue ??= DynInputValue();

    switch (widget.inputType) {
      case DynInputType.tags:
        _tagController = TextfieldTagsController();
        break;

      case DynInputType.image:
        picker = ImagePicker();
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (_tagController != null) {
      _tagController!.dispose();
    }
  }

  Widget buildSingle(BuildContext context) {
    Widget? mainWidget;
    var tWidget = widget.widget;
    var tHint = widget.hint;
    var textInputType = TextInputType.text;
    var inputHeight = 52.0;
    Widget? inContainer;
    List<TextInputFormatter>? inputFormatters;

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
          dropdownColor: kPrimaryHeaderColor,
          borderRadius: BorderRadius.circular(12),
          underline: Container(
            height: 0,
          ),
          items: selectList.map<DropdownMenuItem<String>>((DynInputSelectItem value) {
            return DropdownMenuItem<String>(
              value: value.value,
              child: IntrinsicWidth(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kPrimaryColor,
                      width: 1.0
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Get.isDarkMode ? kPrimaryDarkBackgroundColor : kPrimaryBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(value.label),
                  )
                ),
              )
            );
          }
          ).toList(),
          onChanged: (String? value) {
            setState(() {
              if (value != null) {
                dynValue!.strValue = value;
              }
            });

            if (widget.onChange != null) {
              widget.onChange!();
            }
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

                  if (widget.onChange != null) {
                    widget.onChange!();
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
          if (widget.onFormat != null) {
            tHint = widget.onFormat!(widget.dynValue);
          } else {
            tHint = dynValue!.strValue;
          }
        }
        break;

      case DynInputType.numberdecimal:
        textInputType = const TextInputType.numberWithOptions(decimal: true);

        if (tHint == "") {
          if (widget.onFormat != null) {
            tHint = widget.onFormat!(widget.dynValue);
          } else {
            tHint = dynValue!.strValue;
          }
        }
        break;

      case DynInputType.numberchars:
        textInputType = const TextInputType.numberWithOptions(decimal: true);
        inputFormatters = <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ];

        if (tHint == "") {
          if (widget.onFormat != null) {
            tHint = widget.onFormat!(widget.dynValue);
          } else {
            tHint = dynValue!.strValue;
          }
        }
        break;

      case DynInputType.textarea:
        textInputType = TextInputType.multiline;

        if (tHint == "") {
          if (widget.onFormat != null) {
            tHint = widget.onFormat!(widget.dynValue);
          } else {
            tHint = dynValue!.strValue;
          }
        }

        break;

      case DynInputType.tags:
        List<String> initTagList = [];

        if (dynValue!.strValue != "") {
          try {
            var list = jsonDecode(dynValue!.strValue);

            for (var element in (list as List<dynamic>)) {
              initTagList.add(element);
            }
          } catch(e) {
            if (kDebugMode) {
              print('DynInputValue::buildSingle: ${dynValue!.strValue}');
              print(e);
            }

            initTagList = dynValue!.strValue.split(" ");

          }
        }

        inContainer = Container(
            height: inputHeight,
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
                child: Autocomplete<String>(
                    optionsViewBuilder: (context, onSelected, options) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final dynamic option = options.elementAt(index);
                                  return TextButton(
                                    onPressed: () {
                                      onSelected(option);
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        child: Text(
                                          '#$option',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 74, 137, 92),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }

                      return widget.supportedTagList!.where((String option) {
                        return option.contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selectedTag) {
                      _tagController!.addTag = selectedTag;
                    },
                    fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
                      return TextFieldTags(
                        textfieldTagsController: _tagController,
                        initialTags: initTagList,
                        inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                          return ((context, sc, tags, onTagDelete) {
                            return TextField(
                              controller: tec,
                              focusNode: fn,
                              decoration: InputDecoration(
                                isDense: true,
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
                                ),
                                hintText: _tagController!.hasTags ? '' : "Enter ...",
                                errorText: error,
                                prefixIconConstraints:
                                BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
                                prefixIcon: tags.isNotEmpty
                                    ? SingleChildScrollView(
                                  controller: sc,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: tags.map((String tag) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                            color: kPrimaryColor,
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Text(
                                                  '#$tag',
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                                onTap: () {
                                                  if (kDebugMode) {
                                                    print('DynInputValue::buildSingle:');
                                                    print("$tag selected");
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  onTagDelete(tag);

                                                  try {
                                                    dynValue!.strValue =
                                                        jsonEncode(_tagController!.getTags);
                                                  } catch(e) {
                                                    if (kDebugMode) {
                                                      print('DynInputValue::buildSingle: ${_tagController!.getTags}');
                                                      print(e);
                                                    }
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                )
                                    : null,
                              ),
                              onChanged: onChanged,
                              onSubmitted: (value) {
                                onSubmitted!(value);

                                try {
                                  dynValue!.strValue =
                                      jsonEncode(_tagController!.getTags);
                                } catch(e) {
                                  if (kDebugMode) {
                                    print('DynInputValue::buildSingle: ${_tagController!.getTags}');
                                    print(e);
                                  }
                                }
                              },
                            );
                          });
                        }
                      );
                    },
                  )
                  )
                ],
            )
        );
        break;

      case DynInputType.image:
        if (widget.dynValue!.imgPath != "") {
          _image = File(widget.dynValue!.imgPath);
        }

        inContainer = Container(
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
              border: Border.all(
                  color: kPrimaryColor,
                  width: 1.0
              ),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: _image != null
                    ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Image.file(
                      _image!,
                    ),
                  ),
                )
                    : const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text('No image selected'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DefaultButton(
                    buttonIcon: Icons.image,
                    width: 44,
                    onTab: () {
                      _getImage(ImageSource.gallery);
                    },
                  ),
                  DefaultButton(
                    buttonIcon: Icons.camera,
                    width: 44,
                    onTab: () {
                      _getImage(ImageSource.camera);
                    },
                  )
                ],
              ),
              const SizedBox(height: 10,)
            ],
          ),
        );
        break;

      case DynInputType.nyntogglebtn:
        List<bool> isSelected = [false, false, false];

        if (dynValue!.intValue <= -1) {
          isSelected[0] = true;
        } else if (dynValue!.intValue == 0) {
          isSelected[2] = true;
        } else if (dynValue!.intValue >= 1) {
          isSelected[1] = true;
        }

        inContainer = Container(
          margin: const EdgeInsets.only(top: 8.0),
          padding: const EdgeInsets.only(left: 14),
          child: ToggleButtons(
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                isSelected[index] = !isSelected[index];

                switch (index) {
                  case 0:
                    dynValue!.intValue = -1;
                    break;

                  case 1:
                    dynValue!.intValue = 1;
                    break;

                  case 2:
                    dynValue!.intValue = 0;
                    break;
                }

                if (widget.onChange != null) {
                  widget.onChange!();
                }
              });
            },
            color: Get.isDarkMode ? kPrimaryDarkFontColor :  kPrimaryFontColor,
            selectedColor: Colors.grey[700],
            fillColor: kButtonBackgroundColor,
            borderColor: kPrimaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            children: const [
              Text(' Unknown '),
              Text(' Yes '),
              Text(' No '),
            ]
          ),
        );
        break;

      default:
        if (tHint == "") {
          if (widget.onFormat != null) {
            tHint = widget.onFormat!(widget.dynValue);
          } else {
            tHint = dynValue!.strValue;
          }
        }
    }

    inContainer ??= Container(
        height: inputHeight,
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

                    if (widget.onChange != null) {
                      widget.onChange!();
                    }
                  },
                  initialValue: widget.inputType == DynInputType.textarea ? tHint : null,
                  style: subTitleStyle,
                  keyboardType: textInputType,
                  inputFormatters: inputFormatters,
                  textInputAction: widget.inputType == DynInputType.textarea ? TextInputAction.newline : null,
                  minLines: widget.inputType == DynInputType.textarea ? 20 : null,
                  maxLines: widget.inputType == DynInputType.textarea ? 20 : null,
                  decoration: InputDecoration(
                      counterText: widget.inputType == DynInputType.textarea ? '' : null,
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
        )
    );

    if (widget.inputType == DynInputType.textarea) {
      mainWidget ??= IntrinsicHeight(
        child: inContainer
      );
    } else {
      mainWidget ??= inContainer;
    }

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
                buttonIcon: Icons.add_circle,
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
