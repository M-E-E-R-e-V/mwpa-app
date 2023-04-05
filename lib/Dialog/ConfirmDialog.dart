import 'package:flutter/material.dart';

/// ConfirmDialog
class ConfirmDialog {

  /// show
  static void show(BuildContext context, String dTitle, String msg, Function(String?) onClick) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () => Navigator.pop(context, 'cancel'),
    );

    Widget continueButton = TextButton(
      child: const Text("Ok"),
      onPressed: () => Navigator.pop(context, 'ok'),
    );

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(dTitle),
        content: Text(msg),
        actions: <Widget>[
          cancelButton,
          continueButton,
        ],
      ),
    ).then((tValue) => onClick(tValue));
  }
}