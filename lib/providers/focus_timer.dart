import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Uses a deadline so background tabs and navigation do not delay the timer.
class FocusTimer extends ChangeNotifier {
  FocusTimer(
      {required Future<void> Function(Map<String, dynamic>) save,
      Map<String, dynamic>? initial,
      DateTime Function()? now,
      bool autoTick = true})
      : _save = save,
        _now = now ?? DateTime.now,
        _autoTick = autoTick {
    final state = initial ?? {};
    final minutes = state['minutes'];
    _minutes = [15, 25, 45].contains(minutes) ? minutes as int : 25;
    _remaining =
        (state['remaining'] as num?)?.toInt().clamp(0, _minutes * 60) ??
            _minutes * 60;
    _deadline = DateTime.tryParse(state['deadline']?.toString() ?? '');
    _completed = state['completed'] == true;
    _sessions = (state['sessions'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) =>
            DateTime.tryParse(item['at']?.toString() ?? '') != null &&
            item['minutes'] is int)
        .toList();
    if (running) _startTicker();
  }

  final Future<void> Function(Map<String, dynamic>) _save;
  final DateTime Function() _now;
  final bool _autoTick;
  void _startTicker() {
    _ticker?.cancel();
    if (_autoTick) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
    }
  }

  Timer? _ticker;
  Future<void> _pending = Future.value();
  bool _disposed = false;
  late int _minutes;
  late int _remaining;
  DateTime? _deadline;
  bool _completed = false;
  List<Map<String, dynamic>> _sessions = [];
  String? error;

  int get minutes => _minutes;
  bool get running => _deadline != null;
  bool get completed => _completed;
  int get remainingSeconds => _deadline == null
      ? _remaining
      : max(0, (_deadline!.difference(_now()).inMilliseconds / 1000).ceil());
  double get progress => 1 - remainingSeconds / (_minutes * 60);
  int minutesOn(DateTime day) => _sessions.where((item) {
        final at = DateTime.parse(item['at'] as String).toLocal();
        return at.year == day.year &&
            at.month == day.month &&
            at.day == day.day;
      }).fold(0, (sum, item) => sum + (item['minutes'] as int));

  Map<String, dynamic> toJson() => {
        'minutes': _minutes,
        'remaining': remainingSeconds,
        'deadline': _deadline?.toIso8601String(),
        'completed': _completed,
        'sessions': List<Map<String, dynamic>>.of(_sessions)
      };

  Future<void> _persist() {
    final snapshot = toJson();
    _pending = _pending.then((_) => _save(snapshot)).then((_) {
      error = null;
    }).catchError((Object _) {
      error = 'Não foi possível salvar a sessão neste dispositivo.';
      if (!_disposed) notifyListeners();
    });
    return _pending;
  }

  Future<void> start() async {
    if (running) return;
    if (_completed || _remaining == 0) _remaining = _minutes * 60;
    _completed = false;
    _deadline = _now().add(Duration(seconds: _remaining));
    _startTicker();
    notifyListeners();
    await _persist();
  }

  Future<void> pause() async {
    if (!running) return;
    refresh();
    if (!running) return;
    _remaining = remainingSeconds;
    _deadline = null;
    _ticker?.cancel();
    notifyListeners();
    await _persist();
  }

  Future<void> reset({int? minutes}) async {
    if (minutes != null && ![15, 25, 45].contains(minutes)) return;
    _minutes = minutes ?? _minutes;
    _remaining = _minutes * 60;
    _deadline = null;
    _ticker?.cancel();
    _completed = false;
    notifyListeners();
    await _persist();
  }

  void refresh() {
    if (!running) return;
    if (remainingSeconds == 0) {
      final finishedAt = _deadline!;
      _deadline = null;
      _ticker?.cancel();
      _remaining = 0;
      _completed = true;
      _sessions = [
        {'at': finishedAt.toIso8601String(), 'minutes': _minutes},
        ..._sessions
      ].take(200).toList();
      unawaited(_persist());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
