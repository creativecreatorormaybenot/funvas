import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    this.paused = false,
    required this.funvas,
  }) : super(key: key);

  /// Whether the [funvas] animation should be paused or not.
  ///
  /// This is implemented using [Ticker.muted], which means that pausing the
  /// container will stop the animation from being redrawn. However, the time
  /// in the ticker will still elapse. This means that disabling [paused] again
  /// will cause the animation to jump to the point it would have been at if it
  /// had never been paused.
  ///
  /// To display a funvas animation that never ticks, i.e. displays only a
  /// single frame without any side effects, one should instead use a
  /// [CustomPaint] with a [FunvasPainter] that is passed a static time instead.
  ///
  /// Defaults to false.
  final bool paused;

  /// The [Funvas] that can draw in the container.
  final Funvas funvas;

  @override
  _FunvasContainerState createState() => _FunvasContainerState();
}

class _FunvasContainerState extends State<FunvasContainer>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<double> _time;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _time = ValueNotifier(0);
    _ticker = createTicker(_update)..start();
  }

  @override
  void didUpdateWidget(covariant FunvasContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.funvas != widget.funvas) {
      _time.value = 0;
      _ticker
        ..stop()
        ..start();
    }

    _ticker.muted = widget.paused;
  }

  @override
  void dispose() {
    _time.dispose();
    _ticker.dispose();

    super.dispose();
  }

  void _update(Duration elapsed) {
    _time.value = elapsed.inMicroseconds / 1e6;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: _ticker.isActive,
      painter: FunvasPainter(
        time: _time,
        delegate: widget.funvas,
      ),
    );
  }
}
