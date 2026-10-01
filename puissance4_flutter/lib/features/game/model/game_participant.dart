import 'package:puissance4_client/puissance4_client.dart';

/// Un des deux camps d'une partie, tel qu'affiché : un joueur humain ou un
/// bot (sur le téléphone en Normal, sur le serveur en Classé). `sealed` pour
/// que chaque `switch` traite les deux cas.
sealed class GameParticipant {
  const GameParticipant();

  /// Participant décrit par le serveur (Multi, Classé, replay serveur).
  factory GameParticipant.fromInfo(GamePlayerInfo info) => info.isBot
      ? BotParticipant(name: info.username, elo: info.elo)
      : HumanParticipant(username: info.username, elo: info.elo);

  String get displayName;

  /// `null` quand on ne le connaît pas (ex. bot d'une vieille partie
  /// hors-ligne rejouée sans réseau).
  int? get elo;
}

class HumanParticipant extends GameParticipant {
  const HumanParticipant({required this.username, this.elo});

  final String username;

  @override
  final int? elo;

  @override
  String get displayName => username;
}

class BotParticipant extends GameParticipant {
  const BotParticipant({required this.name, this.elo});

  BotParticipant.fromBot(Bot bot) : this(name: bot.botName, elo: bot.elo);

  final String name;

  @override
  final int? elo;

  @override
  String get displayName => 'Bot $name';
}
