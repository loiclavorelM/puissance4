import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../bot/viewmodel/normal_mode_viewmodel.dart';
import '../../game/model/game_launch.dart';
import '../../game/model/server_game_engine.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../../game/viewmodel/game_viewmodel.dart';
import '../model/ranked_repository.dart';

class RankedState {
  const RankedState({
    this.isStarting = false,
    this.resumablePartieId,
    this.errorMessage,
  });

  final bool isStarting;

  /// Partie serveur déjà en cours : il faut la finir (ou la reprendre) avant
  /// d'en lancer une autre.
  final UuidValue? resumablePartieId;
  final String? errorMessage;
}

final rankedRepositoryProvider = Provider<RankedRepository>(
  (ref) => RankedRepository(),
);

/// Bot que le serveur choisira d'après l'Elo du joueur — mêmes seuils que
/// `RankedEndpoint` (`BotStrength.fromElo`), pour l'annoncer avant de jouer.
final rankedOpponentProvider = Provider<Bot?>((ref) {
  final elo = ref.watch(gameHomeViewModelProvider).elo;
  final bots = ref.watch(botsProvider).valueOrNull ?? const <Bot>[];
  final strength = BotStrength.fromElo(elo);
  for (final bot in bots) {
    if (BotStrength.fromElo(bot.elo) == strength) return bot;
  }
  return null;
});

final rankedViewModelProvider =
    NotifierProvider.autoDispose<RankedViewModel, RankedState>(
      RankedViewModel.new,
    );

/// Écran Classé : lance une partie contre le bot serveur adapté à l'Elo du
/// joueur, ou propose de reprendre celle en cours.
class RankedViewModel extends AutoDisposeNotifier<RankedState> {
  @override
  RankedState build() => const RankedState();

  /// Renvoie de quoi ouvrir l'écran de partie, ou `null` en cas d'échec
  /// (message dans [RankedState.errorMessage]).
  Future<GameLaunch?> start() async {
    if (state.isStarting) return null;
    state = const RankedState(isStarting: true);
    try {
      final partieId = await ref.read(rankedRepositoryProvider).startRanked();
      state = const RankedState();
      return resume(partieId);
    } on GameException catch (error) {
      state = RankedState(
        resumablePartieId: error.reason == EnumGameError.alreadyInGame
            ? error.partieId
            : null,
        errorMessage: error.reason == EnumGameError.alreadyInGame
            ? 'Tu as déjà une partie en cours.'
            : 'Impossible de lancer la partie.',
      );
    } catch (_) {
      state = const RankedState(
        errorMessage: 'Impossible de joindre le serveur. Réessaie.',
      );
    }
    return null;
  }

  GameLaunch resume(UuidValue partieId) {
    final repository = ref.read(serverGameRepositoryProvider);
    return GameLaunch(
      title: 'Classé',
      createEngine: (_) => ServerGameEngine.watch(repository, partieId),
    );
  }
}
