import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/foundation.dart';

import '../ports/ports.dart';

/// État du tableau de bord : la version courante, rechargée quand le
/// serveur en annonce une nouvelle. Un `ChangeNotifier` du SDK, pour ne
/// dépendre d'aucun gestionnaire d'état ; l'app l'enveloppe dans le sien.
class DashboardController extends ChangeNotifier {
  DashboardController(this._repository) {
    _changes = _repository.changes().listen((_) => unawaited(reload()));
  }

  final DashboardRepository _repository;
  late final StreamSubscription<void> _changes;

  Dashboard? _dashboard;
  Object? _error;
  bool _loading = false;
  bool _disposed = false;

  Dashboard? get dashboard => _dashboard;
  Object? get error => _error;
  bool get isLoading => _loading && _dashboard == null;

  Future<void> reload() async {
    _loading = true;
    _notify();
    try {
      _apply(await _repository.load());
    } on Object catch (error) {
      _error = error;
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> saveWidget(WidgetDefinition definition) =>
      _write(() => _repository.saveWidget(definition));

  Future<void> rename(WidgetDefinition widget, String title) =>
      saveWidget(widget.copyWith(title: title));

  Future<void> removeWidget(String id) =>
      _write(() => _repository.removeWidget(id));

  /// `false` s'il n'y avait rien à annuler.
  Future<bool> undo() async {
    final restored = await _repository.undo();
    if (restored == null) return false;
    _apply(restored);
    _notify();
    return true;
  }

  Future<void> setFilters(DashboardFilters filters) =>
      _write(() => _repository.setFilters(filters));

  Future<void> _write(Future<Dashboard> Function() write) async {
    _apply(await write());
    _notify();
  }

  void _apply(Dashboard dashboard) {
    // Une réponse plus ancienne que ce qu'on affiche (course entre une
    // écriture et l'annonce d'une version) est ignorée.
    if (_dashboard != null && dashboard.version < _dashboard!.version) return;
    _dashboard = dashboard;
    _error = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_changes.cancel());
    super.dispose();
  }
}
