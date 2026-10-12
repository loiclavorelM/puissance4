import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/foundation.dart';

import '../ports/ports.dart';

/// Les données d'un widget, chargées par l'app (jamais par le LLM) et
/// rafraîchies selon sa politique :
/// - `live` : quand les données de jeu changent, au plus une fois toutes
///   les `minIntervalSeconds` ;
/// - `interval` : toutes les `minIntervalSeconds` ;
/// - `manual` : seulement sur [reload].
///
/// Les périodes relatives sont recalculées par le serveur à chaque
/// chargement : la fenêtre glisse toute seule.
class WidgetDataController extends ChangeNotifier {
  WidgetDataController(this._client, this._definition, this._filters) {
    _schedule();
    unawaited(reload());
  }

  final DataSourceClient _client;
  WidgetDefinition _definition;
  DashboardFilters _filters;

  SourceData? _data;
  Object? _error;
  bool _loading = false;
  bool _disposed = false;
  DateTime _lastLoad = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<void>? _changes;
  Timer? _timer;
  Timer? _pending;
  int _generation = 0;

  SourceData? get data => _data;
  Object? get error => _error;
  bool get isLoading => _loading && _data == null;

  /// Change la définition ou les filtres ; recharge seulement si ce qui est
  /// demandé au serveur change.
  void update(WidgetDefinition definition, DashboardFilters filters) {
    final before = _request;
    final policy = _definition.refresh;
    _definition = definition;
    _filters = filters;
    if (definition.refresh.mode != policy.mode ||
        definition.refresh.minIntervalSeconds != policy.minIntervalSeconds) {
      _schedule();
    }
    if (_request != before) unawaited(reload());
  }

  String get _request =>
      '${_definition.query.source}|${_filters.resolve(_definition.query.params)}';

  Future<void> reload() async {
    final generation = ++_generation;
    _loading = true;
    _lastLoad = DateTime.now();
    _notify();
    try {
      final data = await _client.query(
        _definition.query.source,
        _filters.resolve(_definition.query.params),
      );
      if (generation != _generation) return;
      _data = data;
      _error = null;
    } on Object catch (error) {
      if (generation != _generation) return;
      _error = error;
    } finally {
      if (generation == _generation) {
        _loading = false;
        _notify();
      }
    }
  }

  void _schedule() {
    unawaited(_changes?.cancel());
    _changes = null;
    _timer?.cancel();
    _timer = null;
    final interval = Duration(seconds: _definition.refresh.minIntervalSeconds);
    switch (_definition.refresh.mode) {
      case RefreshMode.live:
        _changes = _client.dataChanged().listen((_) => _throttled(interval));
      case RefreshMode.interval:
        _timer = Timer.periodic(interval, (_) => unawaited(reload()));
      case RefreshMode.manual:
        break;
    }
  }

  void _throttled(Duration interval) {
    if (_pending != null) return;
    final wait = interval - DateTime.now().difference(_lastLoad);
    if (wait <= Duration.zero) {
      unawaited(reload());
    } else {
      _pending = Timer(wait, () {
        _pending = null;
        unawaited(reload());
      });
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_changes?.cancel());
    _timer?.cancel();
    _pending?.cancel();
    super.dispose();
  }
}
