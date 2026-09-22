import '../generated/protocol.dart';

/// Convertit une couleur de joueur (`EnumColor`, 2 valeurs) en résultat de
/// partie (`EnumOutcome`, 3 valeurs) — nécessaire pour comparer la couleur
/// jouée par quelqu'un à `Partie.winner` sans jamais pouvoir confondre les
/// deux types par erreur (voir `enum_color.spy.yaml`).
extension EnumColorOutcome on EnumColor {
  EnumOutcome get asOutcome =>
      this == EnumColor.rouge ? EnumOutcome.rouge : EnumOutcome.jaune;
}
