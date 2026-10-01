import 'package:puissance4_rules/puissance4_rules.dart';

import '../generated/protocol.dart';

/// Convertit une couleur de joueur (`EnumColor`, 2 valeurs) en résultat de
/// partie (`EnumOutcome`, 3 valeurs) — nécessaire pour comparer la couleur
/// jouée par quelqu'un à `Partie.winner` sans jamais pouvoir confondre les
/// deux types par erreur (voir `enum_color.spy.yaml`).
extension EnumColorOutcome on EnumColor {
  EnumOutcome get asOutcome =>
      this == EnumColor.rouge ? EnumOutcome.rouge : EnumOutcome.jaune;

  /// Même couleur dans `puissance4_rules`.
  Disc get disc => this == EnumColor.rouge ? Disc.rouge : Disc.jaune;

  EnumColor get other =>
      this == EnumColor.rouge ? EnumColor.jaune : EnumColor.rouge;
}

extension DiscColor on Disc {
  EnumColor get color => this == Disc.rouge ? EnumColor.rouge : EnumColor.jaune;
}

extension Connect4OutcomeProtocol on Connect4Outcome {
  EnumOutcome get asOutcome => switch (this) {
    Connect4Outcome.rouge => EnumOutcome.rouge,
    Connect4Outcome.jaune => EnumOutcome.jaune,
    Connect4Outcome.draw => EnumOutcome.draw,
  };
}
