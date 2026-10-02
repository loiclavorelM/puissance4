import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../settings/viewmodel/preferences_viewmodel.dart';
import '../model/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(),
);

final moveExplanationProvider = NotifierProvider.autoDispose
    .family<MoveExplanationViewModel, MoveExplanationState, String>(
      MoveExplanationViewModel.new,
    );

/// Explication du dernier coup d'une position, demandée à la main (bouton
/// « Expliquer ») : chaque appel peut coûter un appel LLM.
sealed class MoveExplanationState {
  const MoveExplanationState();
}

class ExplanationIdle extends MoveExplanationState {
  const ExplanationIdle();
}

class ExplanationLoading extends MoveExplanationState {
  const ExplanationLoading();
}

class ExplanationReady extends MoveExplanationState {
  const ExplanationReady(this.text);
  final String text;
}

class ExplanationFailed extends MoveExplanationState {
  const ExplanationFailed(this.message);
  final String message;
}

/// Famille indexée par la clé de position (`"3,3,4"` : coups jusqu'au coup
/// expliqué inclus), comme le cache du serveur.
class MoveExplanationViewModel
    extends AutoDisposeFamilyNotifier<MoveExplanationState, String> {
  @override
  MoveExplanationState build(String positionKey) => const ExplanationIdle();

  static String keyFor(List<int> moves, int moveIndex) =>
      moves.take(moveIndex + 1).join(',');

  Future<void> explain() async {
    if (state case ExplanationLoading() || ExplanationReady()) return;
    state = const ExplanationLoading();
    final moves = [for (final c in arg.split(',')) int.parse(c)];
    final language =
        ref.read(preferencesViewModelProvider).valueOrNull?.language.name ??
        'fr';
    try {
      final text = await ref
          .read(reviewRepositoryProvider)
          .explainMove(moves, moves.length - 1, language: language);
      state = ExplanationReady(text);
    } on ReviewException catch (e) {
      state = ExplanationFailed(_messageFor(e.reason));
    } on ServerpodClientUnauthorized {
      state = const ExplanationFailed(
        'Connecte-toi pour obtenir une explication.',
      );
    } catch (_) {
      state = const ExplanationFailed(
        'Impossible de joindre le serveur. Réessaie plus tard.',
      );
    }
  }

  static String _messageFor(EnumReviewError reason) => switch (reason) {
    EnumReviewError.invalidMove => 'Ce coup ne peut pas être expliqué.',
    EnumReviewError.notConfigured =>
      "L'explication par IA n'est pas activée sur ce serveur.",
    EnumReviewError.unavailable =>
      "Le service d'explication ne répond pas. Réessaie plus tard.",
    EnumReviewError.rateLimited =>
      "Trop d'explications demandées cette heure-ci. Réessaie plus tard.",
  };
}
