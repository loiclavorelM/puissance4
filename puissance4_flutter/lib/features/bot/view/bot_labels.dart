import 'package:puissance4_rules/puissance4_rules.dart';

import '../../../core/l10n/l10n.dart';

/// Les bots ont un nom en français — niveaux du mode Normal ([BotLevel])
/// comme bots du Classé (`botSeeds` du serveur) : traduits ici pour les
/// niveaux connus (E11), tels quels sinon (anciennes parties).
String localizedBotName(AppLocalizations l10n, String frenchName) =>
    switch (frenchName) {
      'Très facile' => l10n.botVeryEasy,
      'Facile' => l10n.botEasy,
      'Moyen' => l10n.botModerate,
      'Difficile' => l10n.botHard,
      'Débutant' => l10n.botBeginner,
      'Medium' => l10n.botMedium,
      'Expert' => l10n.botExpert,
      _ => frenchName,
    };

String localizedBotDescription(AppLocalizations l10n, BotLevel bot) =>
    switch (bot) {
      BotLevel.tresFacile => l10n.botVeryEasyDescription,
      BotLevel.facile => l10n.botEasyDescription,
      BotLevel.moyen => l10n.botModerateDescription,
      BotLevel.difficile => l10n.botHardDescription,
      BotLevel.expert => l10n.botExpertDescription,
    };
