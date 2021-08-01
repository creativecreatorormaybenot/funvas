import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

/// Funvas animation that draws the Hilbert curve (limited to an order that
/// looks nice).
///
/// The iterative algorithm for translating the node indices to the Cartesian
/// coordinate system is based on the following blog post.
/// http://blog.marcinchwedczuk.pl/iterative-algorithm-for-drawing-hilbert-curve
class ThirtySix extends Funvas {
  static const d = 750.0;

  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    s2q(d);
    // Flip coordinate space vertically to let (0, 0) be the bottom left corner.
    c.translate(0, d);
    c.scale(1, -1);

    // D is the duration of the animation in seconds.
    const D = 9;
    final r = t / D % 2;

    final n = pow(2, 5) ~/ 1;
    final sw = 256 / n, s = (d - sw) / (n - 1);
    final cr = Curves.easeInQuad.transform(r) * 2;
    c.translate(-cr * s * 24, -cr * s * 24);
    _drawHilbertCurve(5, r, const Color(0xffffffff));
    c.translate(s * 24, s * 24);
    _drawHilbertCurve(5, r - 1 / 2, const Color(0xddff0000));
  }

  /// Returns a path that draws the [order] order Hilbert curve but only draws
  /// [nodes] nodes.
  ///
  /// Minimum order is first order. 7 is the last smooth (real time) order.
  void _drawHilbertCurve(int order, double progress, Color color) {
    final n = pow(2, order) ~/ 1, l = n * n, lp = l * progress;
    final sw = 256 / n, s = (d - sw) / (n - 1);
    final p = Path()..moveTo(sw / 2, sw / 2);

    Offset pos(int i, int n) {
      final c = _hni2cc(i % l, n);
      final pos = Offset(c.x * s + sw / 2, c.y * s + sw / 2);
      return pos + const Offset(d, 0) * (i ~/ l / 1);
    }

    void line(Offset o) => p.lineTo(o.dx, o.dy);

    // Draw the Hilbert curve up to a certain node based on time.
    for (var i = 0; i < lp; i++) {
      line(pos(i, n));
    }
    // Animate the curve path going to the next node until we reach it.
    final origin = pos(lp.floor(), n), target = pos(lp.ceil(), n);
    line(Offset.lerp(origin, target, lp - lp.floor())!);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = sw;
    c.drawPath(p, paint);
  }
}

/// Transforms the given node index [i] on a pseudo Hilbert curve of order
/// `2^order = n` to a Cartesian coordinate (Hilbert node index to Cartesian
/// coordinate).
_Crd _hni2cc(int i, int n) {
  // The fixed positions of the first order Hilbert curve (n=2).
  const n2positions = <Point<int>>[
    Point(0, 0),
    Point(0, 1),
    Point(1, 1),
    Point(1, 0),
  ];

  final node = n2positions[_l2b(i)];
  var x = node.x, y = node.y;

  var j = i >>> 2;

  for (var q = 4; q <= n; q *= 2) {
    final r = q ~/ 2;

    switch (_l2b(j)) {
      case 0:
        final tx = x;
        x = y;
        y = tx;
        break;
      case 1:
        y += r;
        break;
      case 2:
        x += r;
        y += r;
        break;
      case 3:
        final ty = y;
        y = (r - 1) - x;
        x = (r - 1) - ty + r;
        break;
    }

    j >>>= 2;
  }
  return _Crd(x.toDouble(), y.toDouble());
}

/// Returns the last two bits of the given integer [x].
///
/// With can simply do this using bitwise AND and `b011` (which is decimal `3`).
int _l2b(int x) => x & /*int.parse('11', radix: 2)*/ 3;

typedef _Crd = Point<double>;
