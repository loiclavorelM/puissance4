import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/local_cache.dart';

final localCacheProvider = Provider<LocalCache>((ref) => LocalCache());
