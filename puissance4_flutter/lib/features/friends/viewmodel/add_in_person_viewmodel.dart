import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../settings/viewmodel/locale_provider.dart';
import 'friends_viewmodel.dart';

/// Le scan de QR code (US15.6) passe par la caméra : téléphone ou
/// navigateur, pas l'ordinateur. Remplacé dans les tests.
final qrScanSupportedProvider = Provider<bool>(
  (ref) =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS,
);

enum ShakePhase {
  /// En attente d'une secousse.
  waiting,

  /// Secousse envoyée, le serveur cherche quelqu'un qui secoue aussi.
  matching,
  found,
  nobody,
}

class ShakeToAddState {
  const ShakeToAddState({
    this.phase = ShakePhase.waiting,
    this.found,
    this.errorMessage,
  });

  final ShakePhase phase;

  /// Le joueur trouvé ([ShakePhase.found]), avec sa relation.
  final PlayerSearchResultDto? found;
  final String? errorMessage;
}

final shakeToAddProvider =
    NotifierProvider.autoDispose<ShakeToAddViewModel, ShakeToAddState>(
      ShakeToAddViewModel.new,
    );

/// « Secouer pour s'ajouter » (US15.6) : chaque secousse demande au serveur
/// qui a secoué en même temps. Le joueur trouvé n'est pas ajouté d'office :
/// on choisit ensuite de lui envoyer une demande.
class ShakeToAddViewModel extends AutoDisposeNotifier<ShakeToAddState> {
  @override
  ShakeToAddState build() => const ShakeToAddState();

  Future<void> onShake() async {
    if (state.phase == ShakePhase.matching) return;
    state = const ShakeToAddState(phase: ShakePhase.matching);
    try {
      final found = await ref.read(friendsRepositoryProvider).shakeToAdd();
      state = found == null
          ? const ShakeToAddState(phase: ShakePhase.nobody)
          : ShakeToAddState(phase: ShakePhase.found, found: found);
    } on FriendsException catch (e) {
      state = ShakeToAddState(
        errorMessage: friendsErrorMessage(ref.read(l10nProvider), e.reason),
      );
    } catch (_) {
      state = ShakeToAddState(
        errorMessage: ref.read(l10nProvider).serverUnreachableLater,
      );
    }
  }
}
