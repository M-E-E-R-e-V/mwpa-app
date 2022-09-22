import 'package:flutter/material.dart';

class ConfirmDialog {

  static void show(BuildContext context, String dtitle, String msg, Function(String?) onClick) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.pop(context, 'cancel'),
    );

    Widget continueButton = TextButton(
      child: Text("Ok"),
      onPressed: () => Navigator.pop(context, 'ok'),
    );

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(dtitle),
        content: Text(msg),
        actions: <Widget>[
          cancelButton,
          continueButton,
        ],
      ),
    ).then((tvalue) => onClick(tvalue));
  }
}