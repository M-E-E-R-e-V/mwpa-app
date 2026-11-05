import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SyncController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/l10n/l10n.dart';
import 'package:provider/provider.dart';

/// SyncStatusLine - top of the sightings tab: when the last sync ran, how
/// many sightings are still open, the error of a failed sync (tap: details)
/// and a button to sync now.
class SyncStatusLine extends StatefulWidget {
  final VoidCallback onSync;
  final void Function(Object error) onShowError;

  const SyncStatusLine({super.key, required this.onSync, required this.onShowError});

  @override
  State<SyncStatusLine> createState() => _SyncStatusLineState();
}

class _SyncStatusLineState extends State<SyncStatusLine> {
  /// keeps "x min ago" current
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// lastSyncText - relative time of the last sync
  static String lastSyncText(BuildContext context, DateTime? last, DateTime now) {
    final l10n = context.l10n;

    if (last == null) {
      return l10n.syncNotYet;
    }

    final age = now.difference(last);

    if (age.inMinutes < 1) {
      return l10n.syncLastJustNow;
    }

    if (age.inMinutes < 60) {
      return l10n.syncLastMinutes(age.inMinutes);
    }

    if (age.inHours < 24) {
      return l10n.syncLastHours(age.inHours);
    }

    return l10n.syncLastDate(DateFormat.yMd().add_Hm().format(last));
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncController>();
    final sightings = context.watch<SightingController>().sightingList;
    final open = sightings
        .where((s) => (s.unid ?? '').isEmpty || s.syncStatus != Sighting.SYNC_STATUS_FINISH)
        .length;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final error = sync.lastError;

    final (IconData icon, Color color, String text) = sync.running
        ? (Icons.sync, scheme.primary, context.l10n.syncRunning)
        : error != null
            ? (
                Icons.sync_problem,
                scheme.error,
                sync.autoStopped ? context.l10n.syncAutoStopped : context.l10n.syncFailedRetry,
              )
            : (
                Icons.cloud_done_outlined,
                scheme.onSurfaceVariant,
                lastSyncText(context, sync.lastSync, DateTime.now()),
              );

    return Material(
      color: error != null && !sync.running
          ? scheme.errorContainer.withValues(alpha: 0.5)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: error != null && !sync.running ? () => widget.onShowError(error) : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: text),
                      if (open > 0)
                        TextSpan(
                          text: '  ·  ${context.l10n.syncOpenCount(open)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: error != null && !sync.running ? scheme.onErrorContainer : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.syncWithServer,
                onPressed: sync.running ? null : widget.onSync,
                icon: const Icon(Icons.sync),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
