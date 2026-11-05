import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/Inputs/InputFrame.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Ui/AppIcons.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';
import 'package:provider/provider.dart';

/// Completeness of a sighting as shown in the list (from
/// [Sighting.validateColor]).
enum SightingState {
  /// required fields missing (date, tour start, begin time/position, count)
  incomplete,

  /// end of trip or end position still open
  endMissing,

  /// species could not be resolved
  unknownSpecies,

  complete,
}

/// ListSightingTile - card of one sighting in the sightings list; [onTap]
/// opens the actions of the sighting.
class ListSightingTile extends StatelessWidget {
  final Sighting sighting;
  final VoidCallback? onTap;

  const ListSightingTile(this.sighting, {super.key, this.onTap});

  static const Color _warningColor = Color(0xffe0a200);
  static const Color _turtleColor = Color(0xff2e9e48);

  void _setEndLocation(BuildContext context) {
    final LocationController locationController = context.read<LocationController>();
    final SightingController sightingController = context.read<SightingController>();

    if (locationController.currentPosition == null) {
      InfoDialog.show(context, 'Info', "Please wait for the GPS signal.");
    } else {
      ConfirmDialog.show(
        context,
        "Set end location/duration",
        "Do you want to set the end location/duration time for this sighting?",
        (p0) {
          if (p0 == 'ok') {
            sighting.location_end = jsonEncode(locationController.currentPosition?.toJson());

            if ( sighting.duration_until == null || sighting.duration_until == 'null' || sighting.duration_until == '') {
              sighting.duration_until = DateFormat('HH:mm').format(DateTime.now());
            }

            sightingController.updateSighting(tSighting: sighting);
            sightingController.getSightings();
          }
        });
    }
  }

  /// _isSet - true for a value the app stores as "set"
  static bool _isSet(String? value) => value != null && value != '' && value != 'null';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // texts -------------------------------------------------------------------

    var timeString = "not set";

    if (sighting.date != null) {
      try {
        final tDate = DateTime.parse(sighting.date!);
        timeString = "${DateFormat.yMd().format(tDate.toLocal())} · ${sighting.duration_from ?? ''}";
      } catch(e) {
        timeString = "${sighting.date!} · ${sighting.duration_from ?? ''}";
      }
    }

    var locationString = "no position";

    if (_isSet(sighting.location_begin)) {
      try {
        final tPos = Position.fromMap(jsonDecode(sighting.location_begin!));
        locationString = UtilPosition.getStr(tPos);
      } catch(locExp) {
        if (kDebugMode) {
          print(locExp);
        }
      }
    }

    String? speciesName = context.read<SpeciesController>().getSpeciesName(sighting.species_id ?? 0);
    var state = switch (sighting.validateColor()) {
      Colors.red => SightingState.incomplete,
      Colors.yellow => SightingState.endMissing,
      _ => SightingState.complete,
    };

    if (speciesName == null && _isSet(sighting.other?.trim())) {
      speciesName = sighting.other!.trim();
    } else if (speciesName == null && _isSet(sighting.note?.trim())) {
      speciesName = sighting.note!.trim();
    }

    if (speciesName == null) {
      speciesName = "Species not found";

      if (state == SightingState.complete) {
        state = SightingState.unknownSpecies;
      }
    }

    // only the common name ("Fin Whale, Finnwal (...)" -> "Fin Whale")
    speciesName = speciesName.split(',')[0];

    final isTurtle = sighting.sightingType == Sighting.TYPE_SHORT;

    final stateColor = switch (state) {
      SightingState.incomplete => scheme.error,
      SightingState.endMissing || SightingState.unknownSpecies => _warningColor,
      SightingState.complete => isTurtle ? _turtleColor : inputAccentColor(context),
    };

    final stateLabel = switch (state) {
      SightingState.incomplete => 'Incomplete',
      SightingState.endMissing => 'End missing',
      SightingState.unknownSpecies => 'Unknown species',
      SightingState.complete => null,
    };

    final endLocationEmpty = !_isSet(sighting.location_end);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    // -------------------------------------------------------------------------

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // status stripe
              Container(width: 6, color: stateColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isTurtle) ...[
                            const Icon(AppIcons.tortoise, size: 20, color: _turtleColor),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              speciesName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _SyncIcon(sighting),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(child: Text(timeString, style: muted, overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 12),
                          Icon(Icons.tag, size: 16, color: scheme.onSurfaceVariant),
                          Text('${sighting.species_count ?? 0}', style: muted),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(locationString, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      if (stateLabel != null || _hasBadges) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (stateLabel != null) _StateChip(stateLabel, stateColor),
                            if ((sighting.subgroups ?? 0) > 0)
                              _Badge(Icons.groups_outlined, 'Subgroups'),
                            if ((sighting.calves ?? 0) > 0 || (sighting.newborns ?? 0) > 0)
                              _Badge(Icons.child_care, 'Calves/newborns'),
                            if (_isSet(sighting.image))
                              _Badge(Icons.photo_outlined, 'Picture'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (endLocationEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.add_location_alt_outlined),
                      tooltip: 'Set end location',
                      onPressed: () => _setEndLocation(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasBadges =>
      (sighting.subgroups ?? 0) > 0 ||
      (sighting.calves ?? 0) > 0 ||
      (sighting.newborns ?? 0) > 0 ||
      _isSet(sighting.image);
}

/// _SyncIcon - local only / changed since sync / synced
class _SyncIcon extends StatelessWidget {
  final Sighting sighting;

  const _SyncIcon(this.sighting);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (icon, color, tooltip) = sighting.unid == ''
        ? (Icons.cloud_off_outlined, scheme.onSurfaceVariant, 'Not synced yet')
        : sighting.syncStatus == Sighting.SYNC_STATUS_OPEN
            ? (Icons.cloud_upload_outlined, ListSightingTile._warningColor, 'Changed, waiting for sync')
            : (Icons.cloud_done_outlined, ListSightingTile._turtleColor, 'Synced');

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StateChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _Badge(this.icon, this.tooltip);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
