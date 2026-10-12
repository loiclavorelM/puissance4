import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'assistant_ui_localizations_en.dart';
import 'assistant_ui_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AssistantUiLocalizations
/// returned by `AssistantUiLocalizations.of(context)`.
///
/// Applications need to include `AssistantUiLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/assistant_ui_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AssistantUiLocalizations.localizationsDelegates,
///   supportedLocales: AssistantUiLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AssistantUiLocalizations.supportedLocales
/// property.
abstract class AssistantUiLocalizations {
  AssistantUiLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AssistantUiLocalizations of(BuildContext context) {
    return Localizations.of<AssistantUiLocalizations>(
      context,
      AssistantUiLocalizations,
    )!;
  }

  static const LocalizationsDelegate<AssistantUiLocalizations> delegate =
      _AssistantUiLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ton tableau de bord est vide'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Demande à l\'assistant d\'ajouter un graphique, ou ajoute-le toi-même.'**
  String get dashboardEmptyBody;

  /// No description provided for @widgetLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger ces données.'**
  String get widgetLoadError;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @widgetNoData.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de partie à montrer.'**
  String get widgetNoData;

  /// No description provided for @widgetEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get widgetEdit;

  /// No description provided for @widgetRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get widgetRename;

  /// No description provided for @widgetRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get widgetRemove;

  /// No description provided for @widgetPin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler'**
  String get widgetPin;

  /// No description provided for @widgetPinned.
  ///
  /// In fr, this message translates to:
  /// **'Épinglé au tableau de bord'**
  String get widgetPinned;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @renameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le widget'**
  String get renameTitle;

  /// No description provided for @others.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get others;

  /// No description provided for @kpiGames.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune partie} =1{1 partie} other{{count} parties}}'**
  String kpiGames(int count);

  /// No description provided for @kpiBest.
  ///
  /// In fr, this message translates to:
  /// **'record : {best}'**
  String kpiBest(int best);

  /// No description provided for @kpiDelta.
  ///
  /// In fr, this message translates to:
  /// **'{delta} pts'**
  String kpiDelta(String delta);

  /// No description provided for @filterAllPeriods.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get filterAllPeriods;

  /// No description provided for @filterAllModes.
  ///
  /// In fr, this message translates to:
  /// **'Tous les modes'**
  String get filterAllModes;

  /// No description provided for @filterAllOpponents.
  ///
  /// In fr, this message translates to:
  /// **'Tous les adversaires'**
  String get filterAllOpponents;

  /// No description provided for @filterClearOpponent.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le filtre adversaire'**
  String get filterClearOpponent;

  /// No description provided for @editorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le widget'**
  String get editorTitle;

  /// No description provided for @editorNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau widget'**
  String get editorNewTitle;

  /// No description provided for @editorSource.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get editorSource;

  /// No description provided for @editorType.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get editorType;

  /// No description provided for @editorMark.
  ///
  /// In fr, this message translates to:
  /// **'Graphique'**
  String get editorMark;

  /// No description provided for @editorX.
  ///
  /// In fr, this message translates to:
  /// **'Axe X'**
  String get editorX;

  /// No description provided for @editorY.
  ///
  /// In fr, this message translates to:
  /// **'Mesure'**
  String get editorY;

  /// No description provided for @editorValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get editorValue;

  /// No description provided for @editorAggregate.
  ///
  /// In fr, this message translates to:
  /// **'Agrégation'**
  String get editorAggregate;

  /// No description provided for @editorColor.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get editorColor;

  /// No description provided for @editorColorNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get editorColorNone;

  /// No description provided for @editorTopN.
  ///
  /// In fr, this message translates to:
  /// **'Top N'**
  String get editorTopN;

  /// No description provided for @editorStack.
  ///
  /// In fr, this message translates to:
  /// **'Empiler'**
  String get editorStack;

  /// No description provided for @editorHorizontal.
  ///
  /// In fr, this message translates to:
  /// **'Barres horizontales'**
  String get editorHorizontal;

  /// No description provided for @editorPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get editorPeriod;

  /// No description provided for @editorFollowDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Comme le tableau de bord'**
  String get editorFollowDashboard;

  /// No description provided for @editorTitleField.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get editorTitleField;

  /// No description provided for @typeKpi.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre clé'**
  String get typeKpi;

  /// No description provided for @typeTable.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get typeTable;

  /// No description provided for @typeChart.
  ///
  /// In fr, this message translates to:
  /// **'Graphique'**
  String get typeChart;

  /// No description provided for @markBar.
  ///
  /// In fr, this message translates to:
  /// **'Barres'**
  String get markBar;

  /// No description provided for @markLine.
  ///
  /// In fr, this message translates to:
  /// **'Courbe'**
  String get markLine;

  /// No description provided for @markArea.
  ///
  /// In fr, this message translates to:
  /// **'Aires'**
  String get markArea;

  /// No description provided for @markDonut.
  ///
  /// In fr, this message translates to:
  /// **'Donut'**
  String get markDonut;

  /// No description provided for @markHeatmap.
  ///
  /// In fr, this message translates to:
  /// **'Carte de chaleur'**
  String get markHeatmap;

  /// No description provided for @aggSum.
  ///
  /// In fr, this message translates to:
  /// **'Somme'**
  String get aggSum;

  /// No description provided for @aggAvg.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get aggAvg;

  /// No description provided for @aggMin.
  ///
  /// In fr, this message translates to:
  /// **'Minimum'**
  String get aggMin;

  /// No description provided for @aggMax.
  ///
  /// In fr, this message translates to:
  /// **'Maximum'**
  String get aggMax;

  /// No description provided for @aggCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre'**
  String get aggCount;

  /// No description provided for @range_last24h.
  ///
  /// In fr, this message translates to:
  /// **'24 h'**
  String get range_last24h;

  /// No description provided for @range_last7d.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get range_last7d;

  /// No description provided for @range_last30d.
  ///
  /// In fr, this message translates to:
  /// **'30 jours'**
  String get range_last30d;

  /// No description provided for @range_last90d.
  ///
  /// In fr, this message translates to:
  /// **'90 jours'**
  String get range_last90d;

  /// No description provided for @range_thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get range_thisWeek;

  /// No description provided for @range_thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get range_thisMonth;

  /// No description provided for @range_thisYear.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get range_thisYear;

  /// No description provided for @range_all.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get range_all;

  /// No description provided for @chatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant'**
  String get chatTitle;

  /// No description provided for @chatHint.
  ///
  /// In fr, this message translates to:
  /// **'Demande un graphique ou pose une question…'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get chatSend;

  /// No description provided for @chatEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : « Ajoute mon taux de victoire, et à côté la carte des cases où je joue sur mes 30 dernières parties. »'**
  String get chatEmpty;

  /// No description provided for @chatNewConversation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get chatNewConversation;

  /// No description provided for @chatThinking.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant réfléchit…'**
  String get chatThinking;

  /// No description provided for @chatTool_list_data_sources.
  ///
  /// In fr, this message translates to:
  /// **'Regarde les données disponibles'**
  String get chatTool_list_data_sources;

  /// No description provided for @chatTool_get_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Lit ton tableau de bord'**
  String get chatTool_get_dashboard;

  /// No description provided for @chatTool_add_widget.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute un widget'**
  String get chatTool_add_widget;

  /// No description provided for @chatTool_propose_widget.
  ///
  /// In fr, this message translates to:
  /// **'Prépare un graphique'**
  String get chatTool_propose_widget;

  /// No description provided for @chatTool_update_widget.
  ///
  /// In fr, this message translates to:
  /// **'Modifie un widget'**
  String get chatTool_update_widget;

  /// No description provided for @chatTool_remove_widget.
  ///
  /// In fr, this message translates to:
  /// **'Retire un widget'**
  String get chatTool_remove_widget;

  /// No description provided for @chatTool_arrange_widgets.
  ///
  /// In fr, this message translates to:
  /// **'Réorganise le tableau de bord'**
  String get chatTool_arrange_widgets;

  /// No description provided for @chatTool_undo_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Annule la dernière modification'**
  String get chatTool_undo_dashboard;

  /// No description provided for @chatTool_set_dashboard_filters.
  ///
  /// In fr, this message translates to:
  /// **'Change les filtres'**
  String get chatTool_set_dashboard_filters;

  /// No description provided for @chatTool_query_data.
  ///
  /// In fr, this message translates to:
  /// **'Consulte tes statistiques'**
  String get chatTool_query_data;

  /// No description provided for @chatTool_analyze_game.
  ///
  /// In fr, this message translates to:
  /// **'Analyse la partie'**
  String get chatTool_analyze_game;

  /// No description provided for @chatError_notConfigured.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant n\'est pas disponible sur ce serveur.'**
  String get chatError_notConfigured;

  /// No description provided for @chatError_unavailable.
  ///
  /// In fr, this message translates to:
  /// **'L\'assistant ne répond pas. Réessaie dans un instant.'**
  String get chatError_unavailable;

  /// No description provided for @chatError_rateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes pour l\'instant. Réessaie plus tard.'**
  String get chatError_rateLimited;

  /// No description provided for @chatError_tooManySteps.
  ///
  /// In fr, this message translates to:
  /// **'Demande trop compliquée : reformule-la plus simplement.'**
  String get chatError_tooManySteps;

  /// No description provided for @chatError_invalidInput.
  ///
  /// In fr, this message translates to:
  /// **'Message invalide.'**
  String get chatError_invalidInput;

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la dernière modification'**
  String get undo;

  /// No description provided for @addWidget.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un widget'**
  String get addWidget;

  /// No description provided for @openAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir l\'assistant'**
  String get openAssistant;
}

class _AssistantUiLocalizationsDelegate
    extends LocalizationsDelegate<AssistantUiLocalizations> {
  const _AssistantUiLocalizationsDelegate();

  @override
  Future<AssistantUiLocalizations> load(Locale locale) {
    return SynchronousFuture<AssistantUiLocalizations>(
      lookupAssistantUiLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AssistantUiLocalizationsDelegate old) => false;
}

AssistantUiLocalizations lookupAssistantUiLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AssistantUiLocalizationsEn();
    case 'fr':
      return AssistantUiLocalizationsFr();
  }

  throw FlutterError(
    'AssistantUiLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
