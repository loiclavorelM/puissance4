import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../game/model/game_launch.dart';
import '../../game/model/server_game_engine.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../../game/viewmodel/game_viewmodel.dart';
import '../model/ranked_repository.dart';
import '../../settings/viewmodel/locale_provider.dart';

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

/// Bot que le serveur choisira d'après l'Elo du joueur — même règle que
/// `RankedEndpoint` (`BotLevel.forElo`), pour l'annoncer avant de jouer.
final rankedOpponentProvider = Provider<BotLevel>(
  (ref) => BotLevel.forElo(ref.watch(gameHomeViewModelProvider).elo),
);

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
            ? ref.read(l10nProvider).alreadyInGame
            : ref.read(l10nProvider).startGameFailed,
      );
    } catch (_) {
      state = RankedState(
        errorMessage: ref.read(l10nProvider).serverUnreachableRetry,
      );
    }
    return null;
  }

  GameLaunch resume(UuidValue partieId) {
    final repository = ref.read(serverGameRepositoryProvider);
    return GameLaunch(
      title: (l10n) => l10n.modeRanked,
      createEngine: (_) => ServerGameEngine.watch(repository, partieId),
    );
  }
}
