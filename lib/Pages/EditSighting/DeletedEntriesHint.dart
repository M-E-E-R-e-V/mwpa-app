import 'package:flutter/material.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Util/UtilDeletedEntries.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// deletedEntriesOf - the entries marked as deleted on the server, from the
/// reference data controllers
DeletedEntries deletedEntriesOf(BuildContext context) {
  return DeletedEntries(
    vehicles: {for (final v in context.read<VehicleController>().deletedVehicles) v.id!: v.name ?? ''},
    drivers: {
      for (final d in context.read<VehicleDriverController>().deletedVehicleDrivers) d.id!: d.username ?? ''
    },
    // label like the select: the part before the first comma
    species: {
      for (final s in context.read<SpeciesController>().deletedSpecies)
        s.orgid!: (s.name ?? '').split(',').first
    },
    behaviours: {
      for (final b in context.read<BehaviouralStateController>().deletedBehaviouralStates) b.id!: b.name ?? ''
    },
    reactions: {
      for (final r in context.read<EncounterCategoriesController>().deletedEncounterCategories) r.id!: r.name ?? ''
    },
  );
}

extension DeletedEntryKindL10n on DeletedEntryKind {
  String label(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      DeletedEntryKind.vehicle => l10n.labelBoat,
      DeletedEntryKind.driver => l10n.labelSkipper,
      DeletedEntryKind.species => l10n.labelSpecies,
      DeletedEntryKind.otherSpecies => l10n.labelOtherSpecies,
      DeletedEntryKind.behaviour => l10n.labelBehaviour,
      DeletedEntryKind.reaction => l10n.labelReaction,
    };
  }
}

/// DeletedEntriesHint - error card on Edit Sighting: the sighting is not
/// synced yet and references entries deleted on the server; tapping one
/// scrolls to the field. Saving is not blocked.
class DeletedEntriesHint extends StatelessWidget {
  final List<DeletedEntry> entries;
  final void Function(DeletedEntryKind kind) onTap;

  const DeletedEntriesHint({super.key, required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: scheme.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.deletedEntriesTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.deletedEntriesInfo,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 4),
            for (final entry in entries)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(entry.kind),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 18, color: scheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.deletedEntryLine(entry.kind.label(context), entry.name),
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: scheme.onErrorContainer),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
