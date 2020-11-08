import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The custom canvas painter that you need to implement in order to paint
/// a funvas.
///
/// This funvas can draw on the available area from (0, 0), which is the origin
/// at the top left of its global position, to the size provided by the context
/// [x] using the canvas [c].
/// All drawing happens in [u].
abstract class Funvas {
  /// Returns the sine of [radians], shorthand for [sin].
  double S(double radians) => sin(radians);

  /// Returns the cosine of [radians], shorthand for [cos].
  double C(double radians) => cos(radians);

  /// Returns the tangent of [radians], shorthand for [tan].
  double T(double radians) => tan(radians);

  /// Returns an RGB(O) color, shorthand for [Color.fromRGBO].
  Color R(num r, num g, num b, [num o]) {
    return Color.fromRGBO(r ~/ 1, g ~/ 1, b ~/ 1, o ?? 1);
  }

  /// The context for the funvas, providing the available size.
  FunvasContext get x => _x;

  /// The canvas for the funvas.
  Canvas get c => _c;

  /// The update function for the funvas based on time [t].
  ///
  /// In this function, you should execute all the canvas operations based on
  /// [t], which is the time since the funvas was inserted into the tree in
  /// seconds.
  void u(double t);

  FunvasContext _x;
  Canvas _c;
}

/// Context for a [Funvas], providing the available size.
@immutable
class FunvasContext {
  /// Constructs a context based on the size values.
  const FunvasContext(this.width, this.height);

  /// The width available to the canvas.
  final double width;

  /// The height available to the canvas.
  final double height;

  @override
  String toString() {
    return 'FunvasContext($width, $height)';
  }
}

/// The [CustomPainter] implementation that provides the [Funvas] with a canvas
/// to draw on.
///
/// We could also use a [LeafRenderObjectWidget] instead, however, the
/// [CustomPainter] abstraction is already pretty much optimized for our use
/// case.
class FunvasPainter extends CustomPainter {
  /// Creates a painter for a funvas using the delegate and time.
  const FunvasPainter({
    @required this.time,
    @required this.delegate,
  })  : assert(time != null),
        assert(delegate != null),
        super(repaint: time);

  /// The time managed by the funvas state.
  final ValueListenable<double> time;

  /// The funvas delegate that takes care of the actual contextual painting.
  final Funvas delegate;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    delegate._c = canvas;
    delegate._x = FunvasContext(size.width, size.height);
    delegate.u(time.value);

    canvas.restore();
  }

  @override
  bool shouldRepaint(FunvasPainter oldPainter) {
    return oldPainter.delegate != delegate;
  }
}
