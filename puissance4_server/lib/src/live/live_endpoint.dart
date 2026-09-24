import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import 'live_notifier.dart';

/// Mises à jour "temps réel" : un stream (WebSocket) par client connecté qui
/// reçoit un [LiveEvent] chaque fois que son profil, son historique ou le
/// Classement change côté serveur — les écritures appellent les helpers de
/// `live_notifier.dart`.
class LiveEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Stream<LiveEvent> watchUpdates(Session session) {
    final authUserId = session.authenticated!.authUserId;
    final sources = [
      session.messages.createStream<LiveEvent>(liveUserChannel(authUserId)),
      session.messages.createStream<LiveEvent>(liveLeaderboardChannel),
    ];

    // Fusion des deux canaux sans dépendre de package:async.
    final controller = StreamController<LiveEvent>();
    final subscriptions = <StreamSubscription<LiveEvent>>[];
    var openSources = sources.length;
    controller.onListen = () {
      for (final source in sources) {
        subscriptions.add(
          source.listen(
            controller.add,
            onError: controller.addError,
            onDone: () {
              if (--openSources == 0) unawaited(controller.close());
            },
          ),
        );
      }
    };
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    return controller.stream;
  }
}
