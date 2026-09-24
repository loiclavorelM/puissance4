import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Passerelles entre les enums générés par Serverpod et ceux de
/// `puissance4_rules` (même rôle que `enum_color_extensions.dart` côté
/// serveur).
extension EnumColorRules on EnumColor {
  Disc get disc => this == EnumColor.rouge ? Disc.rouge : Disc.jaune;

  EnumColor get other =>
      this == EnumColor.rouge ? EnumColor.jaune : EnumColor.rouge;

  EnumOutcome get asOutcome =>
      this == EnumColor.rouge ? EnumOutcome.rouge : EnumOutcome.jaune;
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
