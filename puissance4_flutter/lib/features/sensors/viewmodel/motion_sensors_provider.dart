import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// L'app tourne sur un téléphone (Android, iOS) dont on lit les capteurs de
/// mouvement : secousse, position à plat (E10). Sur le web et l'ordinateur,
/// pas d'accéléromètre fiable — les modes qui en dépendent restent
/// accessibles autrement (Face à face toujours proposé, pas d'indication de
/// secousse). Remplacé dans les tests.
final motionSensorsProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);
