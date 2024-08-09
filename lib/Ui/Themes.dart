import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: kPrimaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kPrimaryBackgroundColor
  );

  static final dark = ThemeData(
    primaryColor: kPrimaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kPrimaryDarkBackgroundColor
  );
}