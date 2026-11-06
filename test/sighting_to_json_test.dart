import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/Sighting.dart';

void main() {
  group('Sighting.toJson other_species (#42)', () {
    test('sends the stored server species ids unchanged', () {
      final raw = jsonEncode({'0': '101', '1': '202'});
      final sighting = Sighting(unid: '', other_species: raw);

      expect(sighting.toJson(false, false)['other_species'], raw);
    });

    test('DB and server payload are the same', () {
      final raw = jsonEncode({'0': '101'});
      final sighting = Sighting(unid: '', other_species: raw);

      expect(sighting.toJson(false, true)['other_species'],
          sighting.toJson(false, false)['other_species']);
    });
  });
}
