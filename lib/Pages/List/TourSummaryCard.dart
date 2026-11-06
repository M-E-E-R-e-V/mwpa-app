import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourSummary.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// TourSummaryCard - head of a tour in the sightings list (and content of
/// the "tour finished" dialog): date and time, duration, distance from the
/// tracking points, number of sightings/animals and the species seen.
class TourSummaryCard extends StatefulWidget {
  final TourSummary summary;

  /// inside a dialog: no card background and margin
  final bool embedded;

  const TourSummaryCard({super.key, required this.summary, this.embedded = false});

  /// distances of finished tours, read once per app run
  static final Map<String, double?> _distanceCache = {};

  @override
  State<TourSummaryCard> createState() => _TourSummaryCardState();
}

class _TourSummaryCardState extends State<TourSummaryCard> {
  double? _storedMeters;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  @override
  void didUpdateWidget(TourSummaryCard old) {
    super.didUpdateWidget(old);

    if (old.summary.tourFid != widget.summary.tourFid) {
      _storedMeters = null;
      _loadDistance();
    }
  }

  Future<void> _loadDistance() async {
    final fid = widget.summary.tourFid;

    if (TourSummaryCard._distanceCache.containsKey(fid)) {
      _storedMeters = TourSummaryCard._distanceCache[fid];
      return;
    }

    try {
      final points = UtilTourSummary.pointsFromJson(await DBHelper.queryTourTrackingLocations(fid));
      final meters = points.length < 2 ? null : UtilTourSummary.routeMeters(points);
      TourSummaryCard._distanceCache[fid] = meters;

      if (mounted && widget.summary.tourFid == fid) {
        setState(() => _storedMeters = meters);
      }
    } catch (error) {
      AppLog.w('List', 'tour distance not readable', error);
    }
  }

  String _durationText(BuildContext context, Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;

    return h == 0 ? context.l10n.durationMinutes(m) : context.l10n.durationHoursMinutes(h, m);
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // running tour: live distance from the recorded route
    final location = context.watch<LocationController>();
    final isCurrent = location.routeTourFid == summary.tourFid;
    final meters = isCurrent ? UtilTourSummary.routeMeters(location.route) : _storedMeters;

    final species = context.read<SpeciesController>();
    final counts = summary.speciesCounts(
      (s) => UtilSighting.displayName(s, species.getSpeciesName(s.species_id ?? 0)),
    );

    String dateText = summary.date ?? '';
    final date = summary.date == null ? null : DateTime.tryParse(summary.date!);

    if (date != null) {
      dateText = DateFormat.yMMMEd().format(date.toLocal());
    }

    final start = summary.start ?? '';
    final hasEnd = UtilTourSummary.minutesOfDay(summary.end) != null;
    final timeText = hasEnd
        ? '$start – ${summary.end}'
        : isCurrent
            ? l10n.tourSince(start)
            : start;

    final duration = summary.duration;
    final stats = <(IconData, String)>[
      if (duration != null) (Icons.timer_outlined, _durationText(context, duration)),
      if (meters != null && meters > 0)
        (
          Icons.route_outlined,
          l10n.distanceNm(NumberFormat('0.0').format(meters / UtilTourSummary.metersPerNauticalMile)),
        ),
      (Icons.visibility_outlined, l10n.sightingsCount(summary.sightings.length)),
      if (summary.animals > 0) (Icons.pets_outlined, l10n.animalsCount(summary.animals)),
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.tour_outlined, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateText,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (start.isNotEmpty)
              Text(timeText, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final (icon, text) in stats)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(text, style: theme.textTheme.bodySmall),
                ],
              ),
          ],
        ),
        if (counts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in counts.take(6))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    entry.value > 1 ? '${entry.key} ×${entry.value}' : entry.key,
                    style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                ),
              if (counts.length > 6)
                Text('+${counts.length - 6}', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      elevation: 0,
      color: scheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: content,
      ),
    );
  }
}

/// TourSummaryDialog - shown after "Tour End"
class TourSummaryDialog {
  static Future<void> show(BuildContext context, TourSummary summary) {
    return showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.flag_circle_outlined, size: 36),
        title: Text(context.l10n.tourFinishedTitle),
        content: SingleChildScrollView(child: TourSummaryCard(summary: summary, embedded: true)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }
}
