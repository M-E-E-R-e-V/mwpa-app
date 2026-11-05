import 'package:flutter/material.dart';

/// Progress of a running sync: [percent] 0..100 and a status [message].
class SyncProgress {
  final int percent;
  final String message;

  const SyncProgress(this.percent, this.message);
}

/// SyncProgressDialog - modal, non-dismissible dialog that shows the sync
/// progress published through [progress]; close it with [close].
class SyncProgressDialog {
  final ValueNotifier<SyncProgress> progress =
      ValueNotifier(const SyncProgress(0, 'Connecting ...'));

  NavigatorState? _navigator;

  /// show - opens the dialog (does not wait for it to close)
  void show(BuildContext context) {
    _navigator = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.cloud_sync_outlined, size: 32),
          title: const Text('Syncing with server'),
          content: ValueListenableBuilder<SyncProgress>(
            valueListenable: progress,
            builder: (context, p, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.percent <= 0 ? null : p.percent / 100,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${p.percent}%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// update - publishes a new progress value
  void update(int percent, String message) {
    progress.value = SyncProgress(percent.clamp(0, 100), message);
  }

  /// close - closes the dialog if it is still open
  void close() {
    _navigator?.pop();
    _navigator = null;
  }
}
