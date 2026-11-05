import 'package:flutter/widgets.dart';
import 'package:mwpaapp/l10n/app_localizations.dart';

export 'package:mwpaapp/l10n/app_localizations.dart';

/// context.l10n - the UI texts in the selected language (lib/l10n/*.arb)
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
