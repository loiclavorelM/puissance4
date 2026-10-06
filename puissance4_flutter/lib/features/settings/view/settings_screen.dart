import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_palette.dart';
import '../../auth/view/create_account_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/view/server_connection_indicator.dart';
import '../../profile/view/edit_profile_screen.dart';
import '../../profile/view/profile_avatar.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../model/app_preferences.dart';
import '../viewmodel/preferences_viewmodel.dart';
import '../../../core/l10n/l10n.dart';

/// context.l10n.settings (E2/E11) — maquette p.7 : COMPTE (pseudo modifiable),
/// PRÉFÉRENCES (langue, thème système/clair/sombre), déconnexion. Pas d'onglet dédié : poussé en route depuis l'icône
/// engrenage de l'écran Jouer (`_MainShell._openSettings`), d'où le bouton
/// retour explicite ci-dessous — pas de nav bar ici pour en sortir.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: context.colors.text),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.settings,
                    style: TextStyle(
                      color: context.colors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  const ServerConnectionIndicator(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _SectionTitle(context.l10n.accountSection),
                  const _AccountCard(),
                  _SectionTitle(context.l10n.preferencesSection),
                  const _PreferencesCard(),
                  const SizedBox(height: 32),
                  OutlinedButton(
                    onPressed: () async {
                      if (!await _confirmSignOut(context, ref)) return;
                      if (!context.mounted) return;
                      // `signOut()` passe `authViewModelProvider` à
                      // `unauthenticated` de façon synchrone (avant son
                      // premier `await`), donc `_AuthGate` a déjà
                      // basculé sur `LoginScreen` en dessous au moment
                      // du pop ci-après — sans ce pop, cette route
                      // poussée depuis l'icône engrenage (voir
                      // `_MainShell._openSettings`) resterait affichée
                      // par-dessus indéfiniment.
                      ref.read(authViewModelProvider.notifier).signOut();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      context.l10n.signOut,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      context.l10n.aboutLine,
                      style: TextStyle(
                        color: context.colors.textFaint,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GuestSignOutChoice { cancel, createAccount, signOut }

/// Un invité (anonyme ou local) qui se déconnecte perd sa progression pour
/// de bon : on le prévient et, s'il est connecté au serveur, on lui propose
/// de créer un compte à la place (US0.2). Un compte email se déconnecte
/// sans confirmation.
Future<bool> _confirmSignOut(BuildContext context, WidgetRef ref) async {
  final isLocalGuest =
      ref.read(authViewModelProvider).status == AuthStatus.localGuest;
  final isGuest = ref.read(myProfileProvider).valueOrNull?.isGuest ?? false;
  if (!isLocalGuest && !isGuest) return true;

  final choice = await showDialog<_GuestSignOutChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.guestSignOutTitle),
      content: Text(context.l10n.guestSignOutMessage),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_GuestSignOutChoice.cancel),
          child: Text(context.l10n.cancel),
        ),
        if (isGuest)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_GuestSignOutChoice.createAccount),
            child: Text(context.l10n.createAccount),
          ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_GuestSignOutChoice.signOut),
          child: Text(context.l10n.signOut),
        ),
      ],
    ),
  );
  if (choice == _GuestSignOutChoice.createAccount && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreateAccountScreen()),
    );
  }
  return choice == _GuestSignOutChoice.signOut;
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final username =
        profile?.username ??
        auth.guestProfile?.username ??
        context.l10n.defaultPlayerName;
    // Invité local : aucun User serveur à modifier (pas d'authUserId).
    final isLocalGuest = auth.status == AuthStatus.localGuest;
    // Invité connecté en anonyme : peut créer un compte en gardant sa
    // progression (US0.2).
    final isGuest = profile?.isGuest ?? false;

    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProfileAvatar(
                username: username,
                thumbnailUrl: profile?.thumbnailUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isLocalGuest)
                      Text(
                        context.l10n.editNeedsServer,
                        style: TextStyle(
                          color: context.colors.textFaint,
                          fontSize: 12,
                        ),
                      )
                    else if (isGuest)
                      Text(
                        context.l10n.guestAccount,
                        style: TextStyle(
                          color: context.colors.textFaint,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: profile == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  disabledForegroundColor: context.colors.outline,
                ),
                child: Text(
                  context.l10n.edit,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (isGuest) ...[
          Divider(height: 1, color: context.colors.fieldFill),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_1,
              color: context.colors.primary,
            ),
            title: Text(
              context.l10n.createAccount,
              style: _rowTitleStyle(context),
            ),
            subtitle: Text(
              context.l10n.guestAccountHint,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.colors.textFaint,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  /// Feuille du bas à choix unique (langue, thème) ; `null` si fermée sans
  /// choisir.
  Future<T?> _pick<T>(
    BuildContext context, {
    required T current,
    required List<T> values,
    required String Function(T value) label,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: context.colors.card,
      builder: (context) => SafeArea(
        child: RadioGroup<T>(
          groupValue: current,
          onChanged: (value) => Navigator.of(context).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final value in values)
                RadioListTile<T>(
                  value: value,
                  activeColor: context.colors.primary,
                  title: Text(
                    label(value),
                    style: TextStyle(color: context.colors.text),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final picked = await _pick(
      context,
      current: current,
      values: AppLanguage.values,
      label: (language) => language.label,
    );
    if (picked != null) {
      await ref.read(preferencesViewModelProvider.notifier).setLanguage(picked);
    }
  }

  Future<void> _pickThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final picked = await _pick(
      context,
      current: current,
      values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
      label: (mode) => _themeModeLabel(context, mode),
    );
    if (picked != null) {
      await ref
          .read(preferencesViewModelProvider.notifier)
          .setThemeMode(picked);
    }
  }

  static String _themeModeLabel(BuildContext context, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.system => context.l10n.themeSystem,
        ThemeMode.light => context.l10n.themeLight,
        ThemeMode.dark => context.l10n.themeDark,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(preferencesViewModelProvider).valueOrNull ??
        AppPreferences.defaults;

    return _Card(
      children: [
        _ChoiceTile(
          title: context.l10n.language,
          value: prefs.language.label,
          onTap: () => _pickLanguage(context, ref, prefs.language),
        ),
        Divider(height: 1, color: context.colors.fieldFill),
        _ChoiceTile(
          title: context.l10n.theme,
          value: _themeModeLabel(context, prefs.themeMode),
          onTap: () => _pickThemeMode(context, ref, prefs.themeMode),
        ),
      ],
    );
  }
}

/// Ligne de préférence : titre, valeur actuelle et chevron vers le choix.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: _rowTitleStyle(context)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: context.colors.textSecondary)),
          Icon(Icons.chevron_right, color: context.colors.textFaint),
        ],
      ),
      onTap: onTap,
    );
  }
}

TextStyle _rowTitleStyle(BuildContext context) => TextStyle(
  color: context.colors.text,
  fontWeight: FontWeight.w600,
);

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.fieldFill),
      ),
      child: Column(children: children),
    );
  }
}
