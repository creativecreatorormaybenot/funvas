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
  /// The context for the funvas, providing the available size.
  FunvasContext get x => _x;
  late FunvasContext _x;

  /// The canvas for the funvas.
  Canvas get c => _c;
  late Canvas _c;

  /// The update function for the funvas based on time [t].
  ///
  /// In this function, you should execute all the canvas operations based on
  /// [t], which is the time since the funvas was inserted into the tree in
  /// seconds.
  void u(double t);

  /// Returns the sine of [radians], shorthand for [sin].
  double S(double radians) => sin(radians);

  /// Returns the cosine of [radians], shorthand for [cos].
  double C(double radians) => cos(radians);

  /// Returns the tangent of [radians], shorthand for [tan].
  double T(double radians) => tan(radians);

  /// Returns an RGB(O) color, shorthand for [Color.fromRGBO].
  Color R(num r, num g, num b, [num? o]) {
    return Color.fromRGBO(r ~/ 1, g ~/ 1, b ~/ 1, (o ?? 1).toDouble());
  }

  /// Scales the canvas to a square with side lengths of [dimension].
  ///
  /// Additionally, translate the canvas, so that the square is centered (in
  /// case the original size does not have an aspect ratio of `1`.
  /// This means that dimensions will not be distorted (pixel aspect ratio will
  /// stay the same) and instead, there will be unused space in case the
  /// original dimensions had a different aspect ratio than `1`.
  /// Furthermore, to ensure the square effect, the square will be clipped.
  ///
  /// The translation and clipping can also be turned off by passing [translate]
  /// and [clip] as false.
  ///
  /// Returns the scaled width and height as a [Size]. If [translate] is `true`,
  /// the returned size will be a square of the given [dimension]. Otherwise,
  /// the returned size might have one side that is larger.
  ///
  /// ### Use cases
  ///
  /// This method is useful if you know that you will be designing a funvas for
  /// certain dimensions. This way, you can use fixed values for all sizes in
  /// the animation and when the funvas is displayed in different dimensions,
  /// your fixed dimensions still work.
  ///
  /// I use this a lot because I know what dimensions I want to have for the
  /// GIF that I will be posting to Twitter beforehand.
  ///
  /// ### Notes
  ///
  /// "s2q" stands for "scale two square". I decided to not use "s2s" because
  /// it sounded a bit weird.
  ///
  /// ---
  ///
  /// My usage recommendation is the following:
  ///
  /// ```dart
  /// final s = s2q(750), w = s.width, h = s.height;
  /// ```
  ///
  /// You could of course simply use a single variable for the dimensions since
  /// `w` and `h` will be equal for a square. However, using my way will allow
  /// you to stay flexible. You could simply disable [translate] later on and/or
  /// use a different aspect ratio :)
  Size s2q(
    double dimension, {
    bool translate = true,
    bool clip = true,
  }) {
    final shortestSide = min(x.width, x.height);
    if (translate) {
      // Center the square.
      c.translate((x.width - shortestSide) / 2, (x.height - shortestSide) / 2);
    }

    final scaling = shortestSide / dimension;
    c.scale(scaling);
    final scaledSize = translate
        ? Size.square(dimension)
        : Size(x.width / scaling, x.height / scaling);

    if (clip) {
      c.clipRect(Offset.zero & scaledSize);
    }

    return scaledSize;
  }
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
    required this.time,
    required this.delegate,
  }) : super(repaint: time);

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
