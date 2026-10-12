import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../l10n/assistant_ui_localizations.dart';
import '../widgets/widget_bodies.dart';
import 'widget_frame.dart';

/// Un widget de la fixture `dashboard`, avec ses données de fixture : un
/// aperçu par type de widget et par moteur de rendu.
Widget _fixture(String id) {
  final dashboard = Dashboard.fromJson(AssistantContracts.fixture('dashboard'));
  final widget = dashboard.widget(id)!;
  final data = SourceData.fromJson(
    AssistantContracts.fixture('data.${widget.query.source}'),
  );
  return Localizations(
    locale: const Locale('fr'),
    delegates: AssistantUiLocalizations.localizationsDelegates,
    child: SizedBox(
      width: 360,
      height: widget.type == WidgetType.kpi ? 130 : 280,
      child: WidgetFrame(
        title: widget.title,
        child: WidgetRegistry.build(widget, data),
      ),
    ),
  );
}

@Preview(name: 'Chiffre clé', group: 'Assistant — widgets')
Widget kpiPreview() => _fixture('w_kpi00001');

@Preview(name: 'Barres empilées', group: 'Assistant — widgets')
Widget stackedBarsPreview() => _fixture('w_byday001');

@Preview(name: 'Barres horizontales', group: 'Assistant — widgets')
Widget horizontalBarsPreview() => _fixture('w_opp00001');

@Preview(name: 'Courbe', group: 'Assistant — widgets')
Widget linePreview() => _fixture('w_elo00001');

@Preview(name: 'Donut', group: 'Assistant — widgets')
Widget donutPreview() => _fixture('w_first001');

@Preview(name: 'Carte de chaleur', group: 'Assistant — widgets')
Widget heatmapPreview() => _fixture('w_cells001');

@Preview(name: 'Tableau', group: 'Assistant — widgets')
Widget tablePreview() => _fixture('w_recent01');
