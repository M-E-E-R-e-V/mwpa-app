import 'package:flutter/material.dart';

/// ConfirmDialog - question with "Cancel" / "Ok"; [onClick] gets 'ok',
/// 'cancel' or null (dismissed).
class ConfirmDialog {
  /// show - with [destructive] the confirm button is shown in the error
  /// color and labelled [okLabel] (e.g. "Delete").
  static void show(
    BuildContext context,
    String dTitle,
    String msg,
    Function(String?) onClick, {
    bool destructive = false,
    String okLabel = 'Ok',
  }) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final scheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: Text(dTitle),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, 'cancel'),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              child: Text(okLabel),
              onPressed: () => Navigator.pop(context, 'ok'),
            ),
          ],
        );
      },
    ).then((tValue) => onClick(tValue));
  }
}
