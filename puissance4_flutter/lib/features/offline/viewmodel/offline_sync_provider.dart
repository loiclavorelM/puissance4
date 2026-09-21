import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/offline_sync_session_holder.dart';

final offlineSyncSessionHolderProvider = Provider<OfflineSyncSessionHolder>(
  (ref) => OfflineSyncSessionHolder(),
);
