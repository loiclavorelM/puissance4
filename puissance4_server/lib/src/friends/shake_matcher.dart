import 'dart:async';

import 'package:serverpod/serverpod.dart';

/// « Secouer pour s'ajouter » (E15, US15.6) : apparie deux joueurs qui
/// secouent leur téléphone à peu près au même moment. Seule autre pièce des
/// Amis à dépendre du nombre de serveurs (avec `PresenceStore`) : en
/// cluster (Redis), une implémentation partagée remplace
/// [InMemoryShakeMatcher] dans `friends_config.dart`.
abstract interface class ShakeMatcher {
  /// [authUserId] vient de secouer : renvoie l'`authUserId` du premier
  /// autre joueur qui secoue dans les [window] qui suivent (ou qui
  /// attendait déjà), sinon `null`.
  Future<UuidValue?> match(UuidValue authUserId, Duration window);
}

class _Waiting {
  _Waiting(this.authUserId);

  final UuidValue authUserId;
  final partner = Completer<UuidValue?>();
}

/// [ShakeMatcher] en mémoire : une file d'attente, appariée dans l'ordre
/// d'arrivée. Aucun `await` entre lecture et écriture : atomique sur
/// l'isolate unique.
class InMemoryShakeMatcher implements ShakeMatcher {
  final _waiting = <_Waiting>[];

  @override
  Future<UuidValue?> match(UuidValue authUserId, Duration window) {
    final index = _waiting.indexWhere((w) => w.authUserId != authUserId);
    if (index >= 0) {
      final other = _waiting.removeAt(index);
      other.partner.complete(authUserId);
      return Future.value(other.authUserId);
    }

    final me = _Waiting(authUserId);
    _waiting.add(me);
    Timer(window, () {
      if (me.partner.isCompleted) return;
      _waiting.remove(me);
      me.partner.complete(null);
    });
    return me.partner.future;
  }
}
