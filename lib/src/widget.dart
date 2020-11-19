import 'dart:async';

import 'package:flutter/material.dart';
import 'package:funvas/src/painter.dart';

/// Widget that allows you to insert a [Funvas] into the widget tree.
///
/// The size available to the funvas is the biggest constraint available to this
/// widget. Therefore, you can size the [FunvasContainer] by wrapping it in a
/// [SizedBox] for example.
class FunvasContainer extends StatefulWidget {
  /// Creates a container that the provided [funvas] can draw in.
  ///
  /// Size and position are provided by the container, i.e. they are provided by
  /// the widget tree above the widget.
  ///
  /// If the [funvas] is changed for the same element in the element tree, the
  /// timer on the state will reset, restarting [Funvas.u] at `0` seconds.
  const FunvasContainer({
    Key? key,
    required this.funvas,
  })  : super(key: key);

  /// The [Funvas] that can draw in the container.
  final Funvas funvas;

  @override
  _FunvasContainerState createState() => _FunvasContainerState();
}

class _FunvasContainerState extends State<FunvasContainer> {
  late final ValueNotifier<double> _time;
  late Timer _timer;
  late DateTime _start;

  @override
  void initState() {
    super.initState();

    _time = ValueNotifier(0);
    _start = DateTime.now();
    _scheduleUpdate();
  }

  @override
  void didUpdateWidget(covariant FunvasContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.funvas != widget.funvas) {
      _time.value = 0;
      _start = DateTime.now();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _time.dispose();

    super.dispose();
  }

  void _scheduleUpdate() {
    _timer = Timer(
      // Lock the update rate to 60 ticks per second, no matter the frame rate.
      Duration(microseconds: 1e6 ~/ 60),
      _update,
    );
  }

  void _update() {
    _time.value = DateTime.now().difference(_start).inMicroseconds / 1e6;
    _scheduleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: FunvasPainter(
        time: _time,
        delegate: widget.funvas,
      ),
    );
  }
}
