import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mwpaapp/Constants.dart';

/// MapStyle - color filter over the OSM tiles so the map matches the app
/// colors (the tiles themselves stay the standard OSM tiles: same source,
/// same cache, same attribution). [tileBuilder] is passed to every
/// TileLayer.
class MapStyle {
  /// tileBuilder - TileLayer.tileBuilder: app blue in light mode, dark map
  /// in dark mode
  static Widget tileBuilder(BuildContext context, Widget tile, TileImage image) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ColorFiltered(
      colorFilter: dark ? _darkFilter : _lightFilter,
      child: tile,
    );
  }

  /// light mode: mostly grey, tinted with the app header blue
  static final List<double> lightMatrix = compose([
    saturation(0.25),
    tint(kPrimaryHeaderColor, 0.16),
    brightness(1.04),
  ]);

  /// dark mode: inverted, hue turned back (water stays blue), dimmed
  static final List<double> darkMatrix = compose([
    invert(),
    hueRotate(180),
    saturation(0.35),
    tint(kPrimaryHeaderColor, 0.12),
    brightness(0.9),
  ]);

  static final ColorFilter _lightFilter = ColorFilter.matrix(lightMatrix);
  static final ColorFilter _darkFilter = ColorFilter.matrix(darkMatrix);

  /// apply - [matrix] applied to one color (tests, previews)
  static Color apply(List<double> matrix, Color c) {
    final rgba = [c.r * 255, c.g * 255, c.b * 255, c.a * 255];
    int ch(int row) {
      var v = matrix[row * 5 + 4];
      for (var k = 0; k < 4; k++) {
        v += matrix[row * 5 + k] * rgba[k];
      }
      return v.round().clamp(0, 255);
    }

    return Color.fromARGB(ch(3), ch(0), ch(1), ch(2));
  }

  // color matrices (4x5, row-major, as ColorFilter.matrix) -------------------

  /// _rows - one 4x5 matrix from its four rows
  static List<double> _rows(List<List<double>> rows) => [for (final row in rows) ...row];

  static List<double> identity() => _rows([
        [1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0],
      ]);

  /// saturation - 0 grey, 1 unchanged
  static List<double> saturation(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final i = 1 - s;

    return _rows([
      [r * i + s, g * i, b * i, 0, 0],
      [r * i, g * i + s, b * i, 0, 0],
      [r * i, g * i, b * i + s, 0, 0],
      [0, 0, 0, 1, 0],
    ]);
  }

  /// tint - mixes [amount] of [color] into every pixel
  static List<double> tint(Color color, double amount) {
    final k = 1 - amount;

    return _rows([
      [k, 0, 0, 0, color.r * 255 * amount],
      [0, k, 0, 0, color.g * 255 * amount],
      [0, 0, k, 0, color.b * 255 * amount],
      [0, 0, 0, 1, 0],
    ]);
  }

  static List<double> brightness(double f) => _rows([
        [f, 0, 0, 0, 0],
        [0, f, 0, 0, 0],
        [0, 0, f, 0, 0],
        [0, 0, 0, 1, 0],
      ]);

  static List<double> invert() => _rows([
        [-1, 0, 0, 0, 255],
        [0, -1, 0, 0, 255],
        [0, 0, -1, 0, 255],
        [0, 0, 0, 1, 0],
      ]);

  /// hueRotate - turns the hue by [degrees] (keeps the luminance)
  static List<double> hueRotate(double degrees) {
    final a = degrees * math.pi / 180;
    final c = math.cos(a), s = math.sin(a);

    return _rows([
      [0.213 + c * 0.787 - s * 0.213, 0.715 - c * 0.715 - s * 0.715, 0.072 - c * 0.072 + s * 0.928, 0, 0],
      [0.213 - c * 0.213 + s * 0.143, 0.715 + c * 0.285 + s * 0.140, 0.072 - c * 0.072 - s * 0.283, 0, 0],
      [0.213 - c * 0.213 - s * 0.787, 0.715 - c * 0.715 + s * 0.715, 0.072 + c * 0.928 + s * 0.072, 0, 0],
      [0, 0, 0, 1, 0],
    ]);
  }

  /// compose - applies the matrices in order (first one first)
  static List<double> compose(List<List<double>> matrices) {
    var result = identity();

    for (final m in matrices) {
      result = _multiply(m, result);
    }

    return result;
  }

  /// _multiply - a after b, both 4x5 (implicit last row 0 0 0 0 1)
  static List<double> _multiply(List<double> a, List<double> b) {
    final out = List<double>.filled(20, 0);

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        var v = 0.0;

        for (var k = 0; k < 4; k++) {
          v += a[row * 5 + k] * b[k * 5 + col];
        }

        if (col == 4) {
          v += a[row * 5 + 4];
        }

        out[row * 5 + col] = v;
      }
    }

    return out;
  }
}
