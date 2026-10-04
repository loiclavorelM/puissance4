import '../../../core/l10n/l10n.dart';
import '../../bot/view/bot_labels.dart';
import '../model/game_participant.dart';

/// Nom d'un camp tel qu'affiché, dans la langue de l'app (« Bot Expert »).
String participantName(AppLocalizations l10n, GameParticipant participant) =>
    switch (participant) {
      HumanParticipant(:final username) => username,
      BotParticipant(:final name) => l10n.botDisplayName(
        localizedBotName(l10n, name),
      ),
    };
