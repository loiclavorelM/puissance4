import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';

/// Les bots arrivent du serveur avec un nom et une description en français
/// (`botSeeds`) : traduits ici pour les niveaux connus (E11), tels quels
/// sinon.
String localizedBotName(AppLocalizations l10n, String serverName) =>
    switch (serverName) {
      'Débutant' => l10n.botBeginner,
      'Medium' => l10n.botMedium,
      'Expert' => l10n.botExpert,
      _ => serverName,
    };

String localizedBotDescription(AppLocalizations l10n, Bot bot) =>
    switch (bot.botName) {
      'Débutant' => l10n.botBeginnerDescription,
      'Medium' => l10n.botMediumDescription,
      'Expert' => l10n.botExpertDescription,
      _ => bot.description,
    };
