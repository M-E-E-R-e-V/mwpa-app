
import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class InfoDialog {

  static void show(BuildContext context, String dtitle, String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              dtitle,
              style: const TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: kPrimaryFontColor,
              ),
            ),
            content: Text(
              msg,
              style: const TextStyle(color: kPrimaryFontColor),
            ),
            backgroundColor: kPrimaryBackgroundColor,
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  primary: kButtonFontColor,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          );
        }
    );
  }
}