import 'package:puissance4_client/puissance4_client.dart';

/// Ce que l'écran de partie reçoit au lancement, quel que soit le mode —
/// Normal (vs bot, stocké hors-ligne), Multi ou Classé (vs joueur, stocké
/// côté serveur). L'écran de partie ne dépend que de ça, jamais de l'écran
/// qui l'a lancé.
class GameSetup {
  const GameSetup({
    required this.mode,
    required this.partieId,
    required this.user,
    required this.adversaire,
    required this.userColor,
  });

  final EnumType mode;

  /// Id de la partie déjà créée : un `OfflineMatchResult` pour
  /// [EnumType.normal], une `Partie` serveur pour Multi/Classé — [mode]
  /// dit laquelle.
  final UuidValue partieId;

  /// Le joueur de cet appareil.
  final GameParticipant user;
  final GameParticipant adversaire;

  /// Couleur jouée par [user] — [adversaire] a l'autre.
  final EnumColor userColor;
}

/// Un des deux camps d'une partie : un bot (Normal) ou un joueur (Multi,
/// Classé). `sealed` pour que chaque `switch` traite les deux cas.
sealed class GameParticipant {
  const GameParticipant();

  String get displayName;
  int get elo;
}

class BotParticipant extends GameParticipant {
  const BotParticipant(this.bot);

  final Bot bot;

  @override
  String get displayName => bot.botName;

  @override
  int get elo => bot.elo;
}

class UserParticipant extends GameParticipant {
  const UserParticipant({required this.username, required this.elo});

  final String username;

  @override
  final int elo;

  @override
  String get displayName => username;
}
