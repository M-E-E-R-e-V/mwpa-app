import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Models/Sighting.dart';

Sighting _complete() => Sighting(
      unid: '',
      date: '2026-11-05 00:00:00.000Z',
      tour_start: '08:00',
      tour_end: '12:00',
      duration_from: '09:10',
      location_begin: '{"latitude":28.1}',
      location_end: '{"latitude":28.2}',
      species_count: 3,
    );

void main() {
  test('complete sighting: nothing missing, header color', () {
    expect(_complete().missingFields(), isEmpty);
    expect(_complete().validateColor(), kPrimaryHeaderColor);
  });

  test('required fields are red, in form order', () {
    final s = _complete()
      ..tour_start = ''
      ..location_begin = 'null'
      ..species_count = 0;

    expect(s.missingFields(), [
      SightingField.tourStart,
      SightingField.beginPosition,
      SightingField.count,
    ]);
    expect(s.validateColor(), Colors.red);
  });

  test('only end of trip / end position open is yellow', () {
    final s = _complete()
      ..tour_end = 'null'
      ..location_end = null;

    expect(s.missingFields(), [SightingField.tourEnd, SightingField.endPosition]);
    expect(s.missingFields().every((f) => f.atEnd), isTrue);
    expect(s.validateColor(), Colors.yellow);
  });

  test('end open and a required field missing is red (was yellow before)', () {
    final s = _complete()
      ..tour_end = ''
      ..duration_from = '';

    expect(s.validateColor(), Colors.red);
  });

  test('tortoise needs no count and is green', () {
    final s = _complete()
      ..species_count = 0
      ..other = 'Chelonia mydas';

    expect(s.missingFields(), isEmpty);
    expect(s.validateColor(), Colors.green);
  });
}
