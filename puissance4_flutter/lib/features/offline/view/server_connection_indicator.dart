import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_connection_tracker.dart';
import '../viewmodel/server_connection_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Petit point de statut de connexion au serveur — vert (joignable), rouge
/// (injoignable) ou gris (pas encore déterminé).
class ServerConnectionIndicator extends ConsumerWidget {
  const ServerConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverConnectionTrackerProvider).status;
    final (color, tooltip) = switch (status) {
      ServerConnectionStatus.connected => (
        Colors.greenAccent,
        context.l10n.statusConnected,
      ),
      ServerConnectionStatus.disconnected => (
        Colors.redAccent,
        context.l10n.statusOffline,
      ),
      ServerConnectionStatus.unknown => (
        Colors.white38,
        context.l10n.statusUnknown,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
