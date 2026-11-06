import 'package:flutter/widgets.dart';

/// AppIcons - icons that are not part of Flutter's Material icon set,
/// taken from the bundled Material Design Icons font
/// (assets/fonts/MaterialDesignIcons.ttf). Unused glyphs are removed at build
/// time by Flutter's icon tree shaking, so keep these `const`.
class AppIcons {
  AppIcons._();

  static const String _fontFamily = 'MaterialDesignIcons';

  /// mdi-tortoise
  static const IconData tortoise = IconData(0xf0d3b, fontFamily: _fontFamily);
}
