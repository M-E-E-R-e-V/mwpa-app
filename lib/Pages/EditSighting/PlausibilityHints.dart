import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilPlausibility.dart';
import 'package:mwpaapp/Util/UtilTourSummary.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// PlausibilityHints - card below the missing-fields summary: values that
/// look wrong (times, date, positions far from the recorded route, counts, distance
/// to the coast, a species new for the area). Tapping
/// a hint scrolls to the field. Only a hint, saving is not blocked.
class PlausibilityHints extends StatelessWidget {
  final List<SightingCheckResult> results;
  final void Function(SightingField field) onTap;

  const PlausibilityHints({super.key, required this.results, required this.onTap});

  static String message(BuildContext context, SightingCheckResult result) {
    final l10n = context.l10n;
    final distance = result.meters == null
        ? ''
        : l10n.distanceNm(
            NumberFormat('0.0').format(result.meters! / UtilTourSummary.metersPerNauticalMile));

    return switch (result.check) {
      SightingCheck.tourEndBeforeStart => l10n.checkTourEndBeforeStart,
      SightingCheck.beginBeforeTourStart => l10n.checkBeginBeforeTourStart,
      SightingCheck.beginAfterTourEnd => l10n.checkBeginAfterTourEnd,
      SightingCheck.endBeforeBegin => l10n.checkEndBeforeBegin,
      SightingCheck.dateInFuture => l10n.checkDateInFuture,
      SightingCheck.beginFarFromTrack => l10n.checkBeginFarFromTrack(distance),
      SightingCheck.endFarFromTrack => l10n.checkEndFarFromTrack(distance),
      SightingCheck.youngButSingleAnimal => l10n.checkYoungButSingleAnimal,
      SightingCheck.subgroupsButSingleAnimal => l10n.checkSubgroupsButSingleAnimal,
      SightingCheck.longSighting => l10n.checkLongSighting,
      SightingCheck.distanceCoastDiffers => l10n.checkDistanceCoastDiffers(distance),
      SightingCheck.unusualSpeciesInArea => l10n.checkUnusualSpeciesInArea,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.tertiaryContainer.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, color: scheme.onTertiaryContainer),
                const SizedBox(width: 10),
                Text(
                  context.l10n.checkTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final result in results)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(result.check.field),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: scheme.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message(context, result),
                          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onTertiaryContainer),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: scheme.onTertiaryContainer),
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
