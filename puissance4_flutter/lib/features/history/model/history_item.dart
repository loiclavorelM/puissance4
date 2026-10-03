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
        adversaire: row.botName,
        // Seules les parties terminées sont lues (voir HistoryRepository).
        resultat: row.result!,
        playedAs: row.playedAs,
        eloVariation: null,
        source: HistorySource.offline,
      );

  final String id;
  final DateTime date;
  final EnumType mode;

  /// Pseudo de l'adversaire (Multi) ou nom du bot tel que donné par le
  /// serveur (Normal, Classé) — mis en forme et traduit par la vue.
  final String adversaire;
  final EnumMatchResult resultat;
  final EnumColor playedAs;
  final int? eloVariation;
  final HistorySource source;
}
