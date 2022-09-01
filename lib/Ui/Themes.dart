import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: kPrimaryColor,
    brightness: Brightness.light,
    backgroundColor: kPrimaryBackgroundColor,
    scaffoldBackgroundColor: kPrimaryBackgroundColor
  );

  static final dark = ThemeData(
    primaryColor: kPrimaryColor,
    brightness: Brightness.dark,
    backgroundColor: kPrimaryDarkBackgroundColor,
    scaffoldBackgroundColor: kPrimaryDarkBackgroundColor
  );
}