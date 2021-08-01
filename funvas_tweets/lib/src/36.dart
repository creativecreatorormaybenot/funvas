import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

/// Funvas animation that draws the Hilbert curve (limited to an order that
/// looks nice).
///
/// The iterative algorithm for translating the node indices to the Cartesian
/// coordinate system is based on the following blog post.
/// http://blog.marcinchwedczuk.pl/iterative-algorithm-for-drawing-hilbert-curve
class ThirtySix extends Funvas {
  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    const d = 750.0;
    s2q(d);
    // Flip coordinate space vertically to let (0, 0) be the bottom left corner.
    c.translate(0, d);
    c.scale(1, -1);

    // n has to be a power of 2. 128 is the last smooth one.
    const n = 16, sw = 256 / n, s = (d - sw) / (n - 1);
    final p = Path()..moveTo(sw / 2, sw / 2);

    // D is the duration of the animation in seconds.
    const D = 18, l = n * n;
    final r = t / D % 1;
    final lp = l * r;
    Offset transform(Point<double> c) =>
        Offset(c.x * s + sw / 2, c.y * s + sw / 2);
    void line(Offset o) => p.lineTo(o.dx, o.dy);

    // Draw the Hilbert curve (order n-1) up to a certain node based on time.
    for (var i = 0; i < lp; i++) {
      line(transform(_hni2cc(i, n)));
    }
    // Animate the curve path going to the next node until we reach it.
    if (lp < l - 1) {
      final origin = _hni2cc(lp.floor(), n), target = _hni2cc(lp.ceil(), n);
      final p = lp - lp.floor();
      final cn = transform(Point(
        lerpDouble(origin.x, target.x, p)!,
        lerpDouble(origin.y, target.y, p)!,
      ));
      line(cn);
    }

    c.translate(-r * d + d / 2, 0);

    final paint = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = sw;
    c.drawPath(p, paint);
  }
}

/// Transforms the given node index [i] on a pseudo Hilbert curve of order
/// `n -1` to a Cartesian coordinate (Hilbert node index to Cartesian
/// coordinate).
Point<double> _hni2cc(int i, int n) {
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
  return Point<double>(x.toDouble(), y.toDouble());
}

/// Returns the last two bits of the given integer [x].
///
/// With can simply do this using bitwise AND and `b011` (which is decimal `3`).
int _l2b(int x) => x & /*int.parse('11', radix: 2)*/ 3;
