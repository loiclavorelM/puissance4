import 'package:puissance4_client/puissance4_client.dart';

/// D'où vient un [HistoryItem] — distingue une `Partie` serveur (Multi/Classé)
/// d'un `OfflineMatchResult` local (Normal). Pas exploité pour l'instant,
/// mais garde la porte ouverte pour le replay (E14) : seul le premier sait
/// répondre à `PartieEndpoint.getPartie(idPartie)`.
enum HistorySource { server, offline }

/// Vue unifiée d'une partie terminée, quelle que soit sa source — c'est ce
/// que la vue Historique affiche, jamais un `HistoryDto`/`OfflineMatchResult`
/// directement.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.date,
    required this.mode,
    required this.adversaire,
    required this.resultat,
    required this.playedAs,
    required this.eloVariation,
    required this.source,
  });

  factory HistoryItem.fromDto(HistoryDto dto) => HistoryItem(
    id: dto.id.toString(),
    date: dto.date,
    mode: dto.typePartie,
    adversaire: dto.adversaire,
    resultat: dto.resultat,
    playedAs: dto.playedAs,
    eloVariation: dto.eloVariation,
    source: HistorySource.server,
  );

  factory HistoryItem.fromOfflineMatchResult(OfflineMatchResult row) =>
      HistoryItem(
        id: row.id!.toString(),
        date: row.playedAt,
        mode: EnumType.normal,
        adversaire: _botLevelLabel(row.botLevel),
        resultat: row.result,
        // OfflineMatchResult ne stocke pas encore la couleur jouée (pas de
        // moteur de jeu réel — E4 pas fait) : le solo vs bot suppose pour
        // l'instant que le joueur joue toujours rouge.
        playedAs: EnumColor.rouge,
        eloVariation: null,
        source: HistorySource.offline,
      );

  final String id;
  final DateTime date;
  final EnumType mode;
  final String adversaire;
  final EnumMatchResult resultat;
  final EnumColor playedAs;
  final int? eloVariation;
  final HistorySource source;

  static String _botLevelLabel(EnumBotLevel level) {
    switch (level) {
      case EnumBotLevel.beginner:
        return 'Bot Débutant';
      case EnumBotLevel.medium:
        return 'Bot Intermédiaire';
      case EnumBotLevel.expert:
        return 'Bot Difficile';
    }
  }
}
