import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_palette.dart';
import '../../profile/view/profile_avatar.dart';

/// Ligne d'un joueur dans l'onglet Amis (liste, demandes, recherche) —
/// même carte que les lignes du Classement.
class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.player,
    this.subtitle,
    this.subtitleColor,
    this.presence,
    this.trailing,
  });

  final FriendUserDto player;
  final String? subtitle;

  /// `textMuted` du thème par défaut.
  final Color? subtitleColor;

  /// Pastille sur l'avatar (amis seulement).
  final EnumFriendPresence? presence;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ProfileAvatar(
                username: player.username,
                thumbnailUrl: player.thumbnailUrl,
                radius: 20,
              ),
              if (presence case final presence?)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: presenceColor(context.colors, presence),
                      border: Border.all(color: context.colors.card, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${player.elo}',
                      style: TextStyle(
                        color: context.colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor ?? context.colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

Color presenceColor(AppPalette colors, EnumFriendPresence presence) =>
    switch (presence) {
      EnumFriendPresence.online => colors.green,
      EnumFriendPresence.playing => colors.yellow,
      EnumFriendPresence.offline => colors.outline,
    };

/// Message centré d'un onglet vide ou en erreur, avec une action facultative.
class FriendsMessage extends StatelessWidget {
  const FriendsMessage({
    super.key,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// `textMuted` du thème par défaut.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color ?? context.colors.textMuted,
                fontSize: 13,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showFriendsSnackBar(BuildContext context, String? message) {
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
