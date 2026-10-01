import 'dart:async';

import 'package:flutter/material.dart';

/// Reconstruit [builder] chaque seconde avec le temps restant avant
/// [deadline] (jamais négatif).
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.deadline, required this.builder});

  final DateTime deadline;
  final Widget Function(Duration remaining) builder;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.deadline.difference(DateTime.now());
    return widget.builder(remaining.isNegative ? Duration.zero : remaining);
  }
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
