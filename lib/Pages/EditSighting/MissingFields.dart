import 'package:flutter/material.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// colors of the hints: required = error color, "at the end" = amber (same
/// as the status stripe in the sightings list)
const Color kAtEndColor = Color(0xffe0a200);

/// localizedLabel - the field name in the UI language
extension SightingFieldL10n on SightingField {
  String localizedLabel(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      SightingField.date => l10n.fieldDate,
      SightingField.tourStart => l10n.fieldTourStart,
      SightingField.tourEnd => l10n.fieldTourEnd,
      SightingField.beginTime => l10n.fieldBeginTime,
      SightingField.beginPosition => l10n.fieldBeginPosition,
      SightingField.endPosition => l10n.fieldEndPosition,
      SightingField.count => l10n.fieldCount,
      SightingField.endTime => l10n.labelUntil,
      SightingField.distanceCoast => l10n.labelDistanceCoast,
      SightingField.species => l10n.labelSpecies,
    };
  }
}

Color _fieldColor(BuildContext context, SightingField field) =>
    field.atEnd ? kAtEndColor : Theme.of(context).colorScheme.error;

/// MissingFieldsSummary - card at the top of the sighting form: which
/// required fields are still empty; tapping one scrolls to it. Only a
/// hint, saving is not blocked.
class MissingFieldsSummary extends StatelessWidget {
  final List<SightingField> missing;
  final void Function(SightingField field) onTap;

  const MissingFieldsSummary({super.key, required this.missing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (missing.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: const Color(0xff2e9e48).withValues(alpha: 0.12),
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Color(0xff2e9e48)),
          title: Text(context.l10n.allRequiredFilled),
        ),
      );
    }

    final required = missing.where((f) => !f.atEnd).toList();
    final atEnd = missing.where((f) => f.atEnd).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: (required.isNotEmpty ? scheme.error : kAtEndColor).withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: required.isNotEmpty ? scheme.error : kAtEndColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.fieldsStillEmpty(missing.length),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (required.isNotEmpty) _group(context, context.l10n.required, required),
            if (atEnd.isNotEmpty) _group(context, context.l10n.atEndOfSighting, atEnd),
            const SizedBox(height: 6),
            Text(
              context.l10n.saveAnywayHint,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<SightingField> fields) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final field in fields)
                ActionChip(
                  avatar: Icon(Icons.arrow_downward, size: 16, color: _fieldColor(context, field)),
                  label: Text(field.localizedLabel(context)),
                  side: BorderSide(color: _fieldColor(context, field)),
                  onPressed: () => onTap(field),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// MissingFieldMark - wraps one input; shows a hint below it while the
/// field is empty. The widget tree is the same with and without hint, so
/// the input keeps its state (focus, cursor) while typing.
class MissingFieldMark extends StatelessWidget {
  final SightingField field;
  final bool missing;
  final Widget child;

  const MissingFieldMark({
    super.key,
    required this.field,
    required this.missing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = _fieldColor(context, field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topLeft,
          child: !missing
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(left: 4, top: 6),
                  child: Row(
                    children: [
                      Icon(field.atEnd ? Icons.schedule : Icons.error_outline, size: 16, color: color),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          field.atEnd ? context.l10n.stillOpenAtEnd : context.l10n.required,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
