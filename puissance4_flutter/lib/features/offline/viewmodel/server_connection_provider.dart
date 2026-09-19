import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/server_connection_tracker.dart';

final serverConnectionTrackerProvider =
    ChangeNotifierProvider<ServerConnectionTracker>(
      (ref) => serverConnectionTracker,
    );
