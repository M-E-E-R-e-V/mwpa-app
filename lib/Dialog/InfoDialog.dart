import 'package:flutter/material.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// InfoDialog - message with a single "Ok" button; follows the app theme
/// (light/dark).
class InfoDialog {
  /// show - [isError] shows the error icon/color
  static void show(BuildContext context, String dTitle, String msg, {bool isError = false}) {

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
              child: Text(context.l10n.ok),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
