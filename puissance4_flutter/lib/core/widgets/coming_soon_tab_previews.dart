import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'coming_soon_tab.dart';

@Preview(name: 'Classement', group: 'ComingSoonTab')
Widget comingSoonTabLeaderboardPreview() {
  return const ComingSoonTab(title: 'Classement');
}

@Preview(name: 'Historique', group: 'ComingSoonTab')
Widget comingSoonTabHistoryPreview() {
  return const ComingSoonTab(title: 'Historique');
}
