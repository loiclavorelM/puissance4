import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../game/model/game_launch.dart';
import '../../history/viewmodel/history_viewmodel.dart';
import '../../game/model/game_participant.dart';
import '../../game/model/local_game_engine.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../../offline/viewmodel/offline_sync_provider.dart';
import '../model/bot_brain.dart';
import '../model/bot_repository.dart';
import '../model/normal_game_recorder.dart';

final botRepositoryProvider = Provider<BotRepository>(
  (ref) => BotRepository(ref.watch(localCacheProvider)),
);

final botsProvider = StreamProvider<List<Bot>>((ref) {
  ref.watch(authViewModelProvider);
  return ref
      .read(botRepositoryProvider)
      .watchBots(client.auth.authInfo?.authUserId);
});

/// La partie est enregistrée dans la session de synchro hors-ligne, qui
/// exige un `authUserId` — impossible en invité local (limitation déjà
/// acceptée, voir `OfflineSyncSessionHolder`).
final canPlayNormalProvider = Provider<bool>(
  (ref) =>
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated,
);

class NormalModeState {
  const NormalModeState({
    this.selectedBot,
    this.isStarting = false,
    this.errorMessage,
  });

  final Bot? selectedBot;
  final bool isStarting;

  /// Échec du dernier "Démarrer", `null` sinon.
  final String? errorMessage;
}

final normalModeViewModelProvider =
    NotifierProvider.autoDispose<NormalModeViewModel, NormalModeState>(
      NormalModeViewModel.new,
    );

/// Écran "Mode Normal — choix du bot" (T5.1.1).
class NormalModeViewModel extends AutoDisposeNotifier<NormalModeState> {
  @override
  NormalModeState build() => const NormalModeState();

  void select(Bot bot) => state = NormalModeState(selectedBot: bot);

  /// Crée la partie hors-ligne et renvoie de quoi ouvrir l'écran de partie,
  /// ou `null` en cas d'échec (message dans [NormalModeState.errorMessage]).
  /// Créée ici plutôt qu'à l'ouverture de l'écran de partie : une erreur
  /// s'affiche là où le joueur peut réessayer, et un rebuild de l'écran de
  /// partie ne peut pas créer de doublon.
  Future<GameLaunch?> start() async {
    final bot = state.selectedBot;
    if (bot == null || state.isStarting) return null;
    state = NormalModeState(selectedBot: bot, isStarting: true);

    try {
      final launch = await createNormalLaunch(ref, bot);
      state = NormalModeState(selectedBot: bot);
      return launch;
    } catch (_) {
      state = NormalModeState(
        selectedBot: bot,
        errorMessage: 'Impossible de créer la partie. Réessaie.',
      );
      return null;
    }
  }
}

/// Crée une partie Normal contre [bot] dans la base locale synchronisée et
/// renvoie de quoi l'ouvrir. Lève si la partie n'a pas pu être créée.
/// Recommençable (secousse, E10) : la suivante se crée de la même façon.
Future<GameLaunch> createNormalLaunch(Ref ref, Bot bot) async {
  // Le joueur commence toujours, en rouge, contre un bot.
  const userColor = EnumColor.rouge;
  final repository = ref.read(offlineGameRepositoryProvider);
  final partieId = await repository.createGame(bot: bot, playedAs: userColor);
  final home = ref.read(gameHomeViewModelProvider);
  final brain = HeuristicBotBrain.forElo(bot.elo);
  return GameLaunch(
    title: 'Normal',
    createEngine: (gameRef) => LocalGameEngine(
      rougeSeat: const HumanSeat(),
      jauneSeat: BotSeat(brain.chooseColumn),
      rouge: HumanParticipant(username: home.username, elo: home.elo),
      jaune: BotParticipant.fromBot(bot),
      myColor: userColor,
      recorder: NormalGameRecorder(
        repository,
        partieId,
        userColor,
        onFinished: () => gameRef.invalidate(offlineHistoryProvider),
      ),
    ),
    restart: (restartRef) => createNormalLaunch(restartRef, bot),
  );
}
