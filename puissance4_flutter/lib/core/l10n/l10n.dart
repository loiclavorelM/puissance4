import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Textes de l'UI dans la langue de l'app (E11) : `context.l10n.xxx`.
/// Hors de l'arbre de widgets (viewmodels, moteurs), lire `l10nProvider`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
