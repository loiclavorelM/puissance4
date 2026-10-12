// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'assistant_ui_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AssistantUiLocalizationsFr extends AssistantUiLocalizations {
  AssistantUiLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get dashboardEmptyTitle => 'Ton tableau de bord est vide';

  @override
  String get dashboardEmptyBody =>
      'Demande à l\'assistant d\'ajouter un graphique, ou ajoute-le toi-même.';

  @override
  String get widgetLoadError => 'Impossible de charger ces données.';

  @override
  String get retry => 'Réessayer';

  @override
  String get widgetNoData => 'Pas encore de partie à montrer.';

  @override
  String get widgetEdit => 'Modifier';

  @override
  String get widgetRename => 'Renommer';

  @override
  String get widgetRemove => 'Retirer';

  @override
  String get widgetPin => 'Épingler';

  @override
  String get widgetPinned => 'Épinglé au tableau de bord';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get renameTitle => 'Renommer le widget';

  @override
  String get others => 'Autres';

  @override
  String kpiGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
      zero: 'aucune partie',
    );
    return '$_temp0';
  }

  @override
  String kpiBest(int best) {
    return 'record : $best';
  }

  @override
  String kpiDelta(String delta) {
    return '$delta pts';
  }

  @override
  String get filterAllPeriods => 'Toujours';

  @override
  String get filterAllModes => 'Tous les modes';

  @override
  String get filterAllOpponents => 'Tous les adversaires';

  @override
  String get filterClearOpponent => 'Retirer le filtre adversaire';

  @override
  String get editorTitle => 'Modifier le widget';

  @override
  String get editorNewTitle => 'Nouveau widget';

  @override
  String get editorSource => 'Données';

  @override
  String get editorType => 'Affichage';

  @override
  String get editorMark => 'Graphique';

  @override
  String get editorX => 'Axe X';

  @override
  String get editorY => 'Mesure';

  @override
  String get editorValue => 'Valeur';

  @override
  String get editorAggregate => 'Agrégation';

  @override
  String get editorColor => 'Séries';

  @override
  String get editorColorNone => 'Aucune';

  @override
  String get editorTopN => 'Top N';

  @override
  String get editorStack => 'Empiler';

  @override
  String get editorHorizontal => 'Barres horizontales';

  @override
  String get editorPeriod => 'Période';

  @override
  String get editorFollowDashboard => 'Comme le tableau de bord';

  @override
  String get editorTitleField => 'Titre';

  @override
  String get typeKpi => 'Chiffre clé';

  @override
  String get typeTable => 'Tableau';

  @override
  String get typeChart => 'Graphique';

  @override
  String get markBar => 'Barres';

  @override
  String get markLine => 'Courbe';

  @override
  String get markArea => 'Aires';

  @override
  String get markDonut => 'Donut';

  @override
  String get markHeatmap => 'Carte de chaleur';

  @override
  String get aggSum => 'Somme';

  @override
  String get aggAvg => 'Moyenne';

  @override
  String get aggMin => 'Minimum';

  @override
  String get aggMax => 'Maximum';

  @override
  String get aggCount => 'Nombre';

  @override
  String get range_last24h => '24 h';

  @override
  String get range_last7d => '7 jours';

  @override
  String get range_last30d => '30 jours';

  @override
  String get range_last90d => '90 jours';

  @override
  String get range_thisWeek => 'Cette semaine';

  @override
  String get range_thisMonth => 'Ce mois-ci';

  @override
  String get range_thisYear => 'Cette année';

  @override
  String get range_all => 'Toujours';

  @override
  String get chatTitle => 'Assistant';

  @override
  String get chatHint => 'Demande un graphique ou pose une question…';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatEmpty =>
      'Par exemple : « Ajoute mon taux de victoire, et à côté la carte des cases où je joue sur mes 30 dernières parties. »';

  @override
  String get chatNewConversation => 'Nouvelle conversation';

  @override
  String get chatThinking => 'L\'assistant réfléchit…';

  @override
  String get chatTool_list_data_sources => 'Regarde les données disponibles';

  @override
  String get chatTool_get_dashboard => 'Lit ton tableau de bord';

  @override
  String get chatTool_add_widget => 'Ajoute un widget';

  @override
  String get chatTool_propose_widget => 'Prépare un graphique';

  @override
  String get chatTool_update_widget => 'Modifie un widget';

  @override
  String get chatTool_remove_widget => 'Retire un widget';

  @override
  String get chatTool_arrange_widgets => 'Réorganise le tableau de bord';

  @override
  String get chatTool_undo_dashboard => 'Annule la dernière modification';

  @override
  String get chatTool_set_dashboard_filters => 'Change les filtres';

  @override
  String get chatTool_query_data => 'Consulte tes statistiques';

  @override
  String get chatTool_analyze_game => 'Analyse la partie';

  @override
  String get chatError_notConfigured =>
      'L\'assistant n\'est pas disponible sur ce serveur.';

  @override
  String get chatError_unavailable =>
      'L\'assistant ne répond pas. Réessaie dans un instant.';

  @override
  String get chatError_rateLimited =>
      'Trop de demandes pour l\'instant. Réessaie plus tard.';

  @override
  String get chatError_tooManySteps =>
      'Demande trop compliquée : reformule-la plus simplement.';

  @override
  String get chatError_invalidInput => 'Message invalide.';

  @override
  String get undo => 'Annuler la dernière modification';

  @override
  String get addWidget => 'Ajouter un widget';

  @override
  String get openAssistant => 'Ouvrir l\'assistant';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get exportTitle => 'Mon tableau de bord Puissance 4';

  @override
  String exportedOn(String date) {
    return 'Exporté le $date';
  }

  @override
  String get exportFailed => 'L\'export PDF a échoué.';

  @override
  String get editorColumns => 'Colonnes';
}
