import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Canaux `session.messages` écoutés par `LiveEndpoint.watchUpdates` — un
/// canal global pour le Classement (tout le monde est concerné) et un canal
/// par `authUserId` pour ce qui ne regarde que lui (profil, historique).
const liveLeaderboardChannel = 'live.leaderboard';
String liveUserChannel(UuidValue authUserId) => 'live.user.${authUserId.uuid}';

/// Groupe de cache local des pages de classement (`LeaderboardEndpoint`).
const leaderboardCacheGroup = 'leaderboard';

/// À appeler après toute écriture qui change l'Elo ou le pseudo d'un `User` :
/// vide le cache du Classement et prévient tous les clients connectés.
Future<void> notifyLeaderboardChanged(Session session) async {
  await session.caches.local.invalidateGroup(leaderboardCacheGroup);
  await session.messages.postMessage(
    liveLeaderboardChannel,
    LiveEvent(type: EnumLiveEventType.leaderboardChanged),
  );
}

/// Prévient les appareils connectés de [authUserId] (ex. un autre téléphone
/// sur le même compte) que son profil, son historique, ses amis, ses défis
/// reçus et/ou son tableau de bord de l'assistant ont changé.
Future<void> notifyUser(
  Session session,
  UuidValue authUserId, {
  bool profile = false,
  bool history = false,
  bool friends = false,
  bool challenges = false,
  bool dashboard = false,
}) async {
  final channel = liveUserChannel(authUserId);
  if (profile) {
    await session.messages.postMessage(
      channel,
      LiveEvent(type: EnumLiveEventType.profileChanged),
    );
  }
  if (history) {
    await session.messages.postMessage(
      channel,
      LiveEvent(type: EnumLiveEventType.historyChanged),
    );
  }
  if (friends) {
    await session.messages.postMessage(
      channel,
      LiveEvent(type: EnumLiveEventType.friendsChanged),
    );
  }
  if (challenges) {
    await session.messages.postMessage(
      channel,
      LiveEvent(type: EnumLiveEventType.challengesChanged),
    );
  }
  if (dashboard) {
    await session.messages.postMessage(
      channel,
      LiveEvent(type: EnumLiveEventType.dashboardChanged),
    );
  }
}

/// Une partie Classé/Multi vient de se terminer pour [authUserId] : stats,
/// historique et Elo (donc Classement) changent tous.
Future<void> notifyPartieFinished(
  Session session,
  UuidValue authUserId,
) async {
  await notifyUser(session, authUserId, profile: true, history: true);
  await notifyLeaderboardChanged(session);
}
