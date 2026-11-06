import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Ui/AppIcons.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// RunningSightings - compact labels on the map for the sightings of the
/// running tour without end position (animals still in view): species, start
/// time and a button that sets the end position. Shows as many as fit into
/// the given height; the rest is a "+n more" label ([onShowAll]).
class RunningSightings extends StatelessWidget {
  /// tour id of the running tour, null: nothing is shown
  final String? tourFid;

  /// tap on a label: open the sighting
  final void Function(Sighting sighting) onOpen;

  /// tap on "+n more": show the sightings list
  final VoidCallback onShowAll;

  const RunningSightings({super.key, required this.tourFid, required this.onOpen, required this.onShowAll});

  /// height of one label and the gap between two
  static const double itemHeight = 36;
  static const double gap = 6;

  /// visibleCount - how many labels fit into [height] for [total] running
  /// sightings; one slot goes to "+n more" when not all fit
  static int visibleCount(double height, int total) {
    final slots = ((height + gap) / (itemHeight + gap)).floor();

    if (slots <= 0 || total == 0) {
      return 0;
    }

    return total <= slots ? total : slots - 1;
  }

  @override
  Widget build(BuildContext context) {
    final sightings = context.watch<SightingController>().sightingList;
    final running = UtilSighting.runningSightings(sightings, tourFid);

    if (running.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final shown = visibleCount(constraints.maxHeight, running.length);
        final hidden = running.length - shown;
        final slots = ((constraints.maxHeight + gap) / (itemHeight + gap)).floor();

        final labels = <Widget>[
          for (final s in running.take(shown)) _RunningLabel(sighting: s, onTap: () => onOpen(s)),
          if (hidden > 0 && slots > 0) _MoreLabel(count: hidden, onTap: onShowAll),
        ];

        // all labels as wide as the widest (at most 260)
        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                labels[i],
              ],
            ],
          ),
        );
      },
    );
  }
}

/// _RunningLabel - one running sighting in one line: icon, name · start
/// time, end-position button
class _RunningLabel extends StatelessWidget {
  final Sighting sighting;
  final VoidCallback onTap;

  const _RunningLabel({required this.sighting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isTurtle = sighting.sightingType == Sighting.TYPE_SHORT;

    final name = UtilSighting.displayName(
          sighting,
          context.read<SpeciesController>().getSpeciesName(sighting.species_id ?? 0),
        ) ??
        context.l10n.speciesNotFound;
    final from = sighting.duration_from;

    return Material(
      color: scheme.surface.withValues(alpha: 0.93),
      elevation: 3,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: RunningSightings.itemHeight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // status stripe: end position missing
                Container(width: 4, color: ListSightingTile.warningColor),
                const SizedBox(width: 8),
                Icon(
                  isTurtle ? AppIcons.tortoise : Icons.visibility_outlined,
                  size: 18,
                  color: isTurtle ? ListSightingTile.turtleColor : kButtonBackgroundColor,
                ),
                const SizedBox(width: 6),
                // the name shortens, the start time stays readable
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (from != null && from.trim().isNotEmpty && from != 'null')
                        Text(
                          ' · $from',
                          maxLines: 1,
                          style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.setEndLocation,
                  onPressed: () => ListSightingTile.setEndLocation(context, sighting),
                  icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                  color: kButtonBackgroundColor,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// _MoreLabel - "+n more" when not all running sightings fit
class _MoreLabel extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _MoreLabel({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface.withValues(alpha: 0.93),
      elevation: 3,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            context.l10n.runningMore(count),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
