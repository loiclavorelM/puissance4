import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../history/viewmodel/history_viewmodel.dart';
import '../../offline/viewmodel/offline_sync_provider.dart';
import '../model/game_setup.dart';

class GameState {
  const GameState({this.isFinishing = false, this.errorMessage});

  final bool isFinishing;
  final String? errorMessage;
}

final gameViewModelProvider = NotifierProvider.autoDispose
    .family<GameViewModel, GameState, GameSetup>(GameViewModel.new);

/// Partie en cours — pour l'instant sans plateau (E4 pas fait) : ne sait que
/// clore la partie avec un résultat choisi à la main.
class GameViewModel extends AutoDisposeFamilyNotifier<GameState, GameSetup> {
  @override
  GameState build(GameSetup setup) => const GameState();

  /// Renvoie `true` si la partie a bien été close.
  Future<bool> finish(EnumMatchResult result) async {
    if (state.isFinishing) return false;
    state = const GameState(isFinishing: true);
    try {
      switch (arg.mode) {
        case EnumType.normal:
          await ref
              .read(offlineGameRepositoryProvider)
              .finishGame(arg.partieId, result);
          ref.invalidate(offlineHistoryProvider);
        case EnumType.multi || EnumType.classe:
          // Parties serveur (E4/E7) — pas encore de moteur de jeu.
          throw UnimplementedError('Mode ${arg.mode} pas encore jouable.');
      }
    } catch (_) {
      state = const GameState(
        errorMessage: 'Impossible de terminer la partie. Réessaie.',
      );
      return false;
    }
    state = const GameState();
    return true;
  }
}
