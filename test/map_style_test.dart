import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Ui/MapStyle.dart';

void main() {
  int lum(Color c) => ((c.r + c.g + c.b) * 255 / 3).round();

  test('saturation(1) and an empty compose change nothing', () {
    const c = Color(0xff3a7bd5);
    expect(MapStyle.apply(MapStyle.compose([]), c), c);
    expect(MapStyle.apply(MapStyle.saturation(1), c), c);
  });

  test('saturation(0) gives grey, invert flips', () {
    final grey = MapStyle.apply(MapStyle.saturation(0), const Color(0xffff0000));
    expect(grey.r, grey.g);
    expect(grey.g, grey.b);
    expect(MapStyle.apply(MapStyle.invert(), const Color(0xff000000)), const Color(0xffffffff));
  });

  test('light map: OSM colors become calm and bluish, stay light', () {
    // OSM land, park green and water
    for (final c in const [Color(0xfff2efe9), Color(0xffc8facc), Color(0xffaad3df)]) {
      final out = MapStyle.apply(MapStyle.lightMatrix, c);
      expect(out.b, greaterThanOrEqualTo(out.r), reason: '$c');
      expect(lum(out), greaterThan(170), reason: '$c');
    }
  });

  test('dark map: land dark, water stays blue, alpha kept', () {
    final land = MapStyle.apply(MapStyle.darkMatrix, const Color(0xfff2efe9));
    final water = MapStyle.apply(MapStyle.darkMatrix, const Color(0xffaad3df));

    expect(lum(land), lessThan(70));
    expect(water.b, greaterThan(water.r));
    expect(land.a, 1.0);
  });
}
