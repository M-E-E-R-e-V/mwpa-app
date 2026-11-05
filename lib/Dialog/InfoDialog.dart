import 'package:flutter/material.dart';

/// InfoDialog - message with a single "Ok" button; follows the app theme
/// (light/dark).
class InfoDialog {
  static void show(BuildContext context, String dTitle, String msg) {
    final isError = dTitle.toLowerCase().contains('error');

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final scheme = Theme.of(context).colorScheme;

        return AlertDialog(
          icon: Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: isError ? scheme.error : scheme.primary,
            size: 32,
          ),
          title: Text(dTitle),
          content: Text(msg),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
