import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

enum DynInputType {
  text,
  date,
}

class DynInput extends StatelessWidget {
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

  _getDateFromUser() async {
    DateTime? _pickeDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2120)
    );
  }

  @override
  Widget build(BuildContext context) {
    var tWidget = widget;

    switch (inputType) {
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
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Container(
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
                    controller: controller,
                    style: subTitleStyle,
                    decoration: InputDecoration(
                      hintText: hint,
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
          )
        ],
      ),
    );
  }
}
