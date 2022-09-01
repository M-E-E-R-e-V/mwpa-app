import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {

  final _box = GetStorage();
  final _key = "isDarkMode";

  bool _loadTheme() {
    return _box.read(_key) ?? false;
  }

  _saveTheme(bool isDarkMode) {
    _box.write(_key, isDarkMode);
  }

  ThemeMode get theme {
    return _loadTheme() ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    Get.changeThemeMode(_loadTheme() ? ThemeMode.light : ThemeMode.dark);
    _saveTheme(!_loadTheme());
  }
}