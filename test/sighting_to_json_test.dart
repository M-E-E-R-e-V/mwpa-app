import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Models/Species.dart';

void main() {
  group('Sighting.toJson forSync', () {
    final species = {
      1: Species(id: 1, orgid: 101, name: 'Tursiops truncatus'),
      2: Species(id: 2, orgid: 202, name: 'Delphinus delphis'),
    };

    Species? lookup(int id) => species[id];

    test('translates other_species local ids to org ids', () {
      final sighting = Sighting(
        unid: '',
        other_species: jsonEncode({'0': '1', '1': '2', '2': ''}),
      );

      final data = sighting.toJson(false, false, true, speciesById: lookup);

      expect(jsonDecode(data['other_species']), {'0': '101', '1': '202'});
    });

    test('keeps other_species unchanged when not syncing', () {
      final raw = jsonEncode({'0': '1'});
      final sighting = Sighting(unid: '', other_species: raw);

      final data = sighting.toJson(false, true, false);

      expect(data['other_species'], raw);
    });

    test('requires a species lookup when syncing', () {
      final sighting = Sighting(unid: '', other_species: jsonEncode({'0': '1'}));

      expect(
        () => sighting.toJson(false, false, true),
        throwsArgumentError,
      );
    });
  });
}
