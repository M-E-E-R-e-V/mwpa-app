import 'dart:convert';

import 'package:mwpaapp/Models/Sighting.dart';

/// DeletedEntryKind - a reference field of a sighting
enum DeletedEntryKind { vehicle, driver, species, otherSpecies, behaviour, reaction }

/// DeletedEntry - the sighting references an entry the server marked as
/// deleted ([name] for the message)
class DeletedEntry {
  final DeletedEntryKind kind;
  final String name;

  const DeletedEntry(this.kind, this.name);

  @override
  bool operator ==(Object other) => other is DeletedEntry && other.kind == kind && other.name == name;

  @override
  int get hashCode => Object.hash(kind, name);
}

/// DeletedEntries - names of the entries marked as deleted on the server, by
/// the id a sighting stores (species: server id orgid)
class DeletedEntries {
  final Map<int, String> vehicles;
  final Map<int, String> drivers;
  final Map<int, String> species;
  final Map<int, String> behaviours;
  final Map<int, String> reactions;

  const DeletedEntries({
    this.vehicles = const {},
    this.drivers = const {},
    this.species = const {},
    this.behaviours = const {},
    this.reactions = const {},
  });

  bool get isEmpty =>
      vehicles.isEmpty && drivers.isEmpty && species.isEmpty && behaviours.isEmpty && reactions.isEmpty;
}

/// UtilDeletedEntries - a sighting that is not synced yet must not reference
/// entries deleted on the server (it would be sent with them); already
/// synced sightings keep showing them without a hint
class UtilDeletedEntries {
  /// isUnsynced - not on the server yet, or changed since the last upload
  static bool isUnsynced(Sighting s) =>
      (s.unid ?? '').isEmpty || s.syncStatus != Sighting.SYNC_STATUS_FINISH;

  /// check - the deleted entries [s] references (in form order)
  static List<DeletedEntry> check(Sighting s, DeletedEntries deleted) {
    if (deleted.isEmpty) {
      return const [];
    }

    final result = <DeletedEntry>[];

    void single(DeletedEntryKind kind, int? id, Map<int, String> names) {
      final name = id == null ? null : names[id];

      if (name != null) {
        result.add(DeletedEntry(kind, name));
      }
    }

    void multi(DeletedEntryKind kind, String? json, Map<int, String> names) {
      for (final id in _ids(json)) {
        final name = names[id];

        if (name != null) {
          result.add(DeletedEntry(kind, name));
        }
      }
    }

    single(DeletedEntryKind.vehicle, s.vehicle_id, deleted.vehicles);
    single(DeletedEntryKind.driver, s.vehicle_driver_id, deleted.drivers);
    single(DeletedEntryKind.species, s.species_id, deleted.species);
    multi(DeletedEntryKind.behaviour, s.behaviours, deleted.behaviours);
    single(DeletedEntryKind.reaction, s.reaction_id, deleted.reactions);
    multi(DeletedEntryKind.otherSpecies, s.other_species, deleted.species);

    return result;
  }

  /// ids of a multi-select value ({"0": "12", "1": "3"})
  static Iterable<int> _ids(String? json) {
    if (json == null || json.isEmpty) {
      return const [];
    }

    try {
      final data = jsonDecode(json);

      if (data is! Map) {
        return const [];
      }

      return data.values.map((v) => int.tryParse('$v')).whereType<int>();
    } catch (_) {
      return const [];
    }
  }
}
