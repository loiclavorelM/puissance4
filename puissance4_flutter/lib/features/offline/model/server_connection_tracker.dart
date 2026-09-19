import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:serverpod_client/serverpod_client.dart';

enum ServerConnectionStatus { unknown, connected, disconnected }

/// Suit la joignabilité du serveur à partir des vrais appels RPC de l'app
/// (via les hooks `onSucceededCall`/`onFailedCall` du client généré) — pas
/// de ping en boucle. [ServerpodClientNetworkException] est la seule
/// exception qui signifie vraiment "serveur injoignable" ; toute
/// [ServerpodClientHttpException] (401, 404, 500...) prouve au contraire
/// qu'il a répondu.
class ServerConnectionTracker extends ChangeNotifier {
  ServerConnectionStatus _status = ServerConnectionStatus.unknown;
  ServerConnectionStatus get status => _status;

  bool _hasNetwork = true; // optimiste jusqu'au premier événement OS connu
  bool get hasNetwork => _hasNetwork;

  /// Vrai seulement quand l'OS dit "réseau dispo" mais que nos propres
  /// appels échouent quand même — le seul cas qui mérite d'être signalé
  /// explicitement à l'utilisateur (un simple "pas de réseau" est déjà
  /// évident pour lui, pas la peine d'insister dessus).
  bool get isServerUnreachableDespiteNetwork =>
      _hasNetwork && _status == ServerConnectionStatus.disconnected;

  // Riverpod's ChangeNotifierProvider passes the *same* mutable instance as
  // both "previous" and "next" on every notification (this tracker is a
  // singleton, mutated in place), so `ref.listen` can never tell "was
  // false, now true" apart from "is true" by comparing them. This stream
  // fires exactly once per genuine transition instead, computed here from
  // the real before/after values, before either field is overwritten.
  final _unreachableController = StreamController<void>.broadcast();
  Stream<void> get onUnreachableDespiteNetwork => _unreachableController.stream;

  void updateNetworkAvailability(bool hasNetwork) {
    if (_hasNetwork == hasNetwork) return;
    final wasProblem = isServerUnreachableDespiteNetwork;
    _hasNetwork = hasNetwork;
    _notifyProblemTransition(wasProblem);
  }

  void markSucceeded() => _setStatus(ServerConnectionStatus.connected);

  void markFailed(Object error) {
    final unreachable = switch (error) {
      ServerpodClientNetworkException() => true,
      ServerpodClientHttpException() => false,
      ServerpodClientUnknownException() => false,
      _ => false,
    };
    _setStatus(
      unreachable
          ? ServerConnectionStatus.disconnected
          : ServerConnectionStatus.connected,
    );
  }

  void _setStatus(ServerConnectionStatus value) {
    if (_status == value) return;
    final wasProblem = isServerUnreachableDespiteNetwork;
    _status = value;
    _notifyProblemTransition(wasProblem);
  }

  void _notifyProblemTransition(bool wasProblem) {
    final isProblem = isServerUnreachableDespiteNetwork;
    if (!wasProblem && isProblem) {
      _unreachableController.add(null);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_unreachableController.close());
    super.dispose();
  }
}

/// Instance globale unique, même schéma que `client` dans `client.dart`.
final serverConnectionTracker = ServerConnectionTracker();
