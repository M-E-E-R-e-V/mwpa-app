import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilDeletedEntries.dart';

void main() {
  const deleted = DeletedEntries(
    vehicles: {5: 'Catherina'},
    drivers: {7: 'Sven'},
    species: {42: 'Orcinus orca'},
    behaviours: {9: 'SLOW TRAVEL'},
    reactions: {3: 'Interaktiv'},
  );

  group('UtilDeletedEntries.check', () {
    test('finds every deleted reference, in form order', () {
      final s = Sighting(
        unid: '',
        vehicle_id: 5,
        vehicle_driver_id: 7,
        species_id: 42,
        behaviours: jsonEncode({'0': '1', '1': '9'}),
        reaction_id: 3,
        other_species: jsonEncode({'0': '42', '1': '23'}),
      );

      expect(UtilDeletedEntries.check(s, deleted), const [
        DeletedEntry(DeletedEntryKind.vehicle, 'Catherina'),
        DeletedEntry(DeletedEntryKind.driver, 'Sven'),
        DeletedEntry(DeletedEntryKind.species, 'Orcinus orca'),
        DeletedEntry(DeletedEntryKind.behaviour, 'SLOW TRAVEL'),
        DeletedEntry(DeletedEntryKind.reaction, 'Interaktiv'),
        DeletedEntry(DeletedEntryKind.otherSpecies, 'Orcinus orca'),
      ]);
    });

    test('active entries, empty and broken values give no hint', () {
      final s = Sighting(
        unid: '',
        vehicle_id: 1,
        vehicle_driver_id: null,
        species_id: 23,
        behaviours: '',
        other_species: 'not json',
      );

      expect(UtilDeletedEntries.check(s, deleted), isEmpty);
      expect(UtilDeletedEntries.check(Sighting(unid: '', vehicle_id: 5), const DeletedEntries()), isEmpty);
    });
  });

  test('isUnsynced: new or changed since the upload', () {
    expect(UtilDeletedEntries.isUnsynced(Sighting(unid: '', syncStatus: Sighting.SYNC_STATUS_OPEN)), isTrue);
    expect(UtilDeletedEntries.isUnsynced(Sighting(unid: 'u1', syncStatus: Sighting.SYNC_STATUS_OPEN)), isTrue);
    expect(UtilDeletedEntries.isUnsynced(Sighting(unid: 'u1', syncStatus: Sighting.SYNC_STATUS_FINISH)), isFalse);
  });
}
