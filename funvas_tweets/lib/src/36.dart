import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

/// Funvas animation that draws the Hilbert curve (limited to an order that
/// looks nice).
///
/// The iterative algorithm for translating the node indices to the Cartesian
/// coordinate system is based on the following blog post.
/// http://blog.marcinchwedczuk.pl/iterative-algorithm-for-drawing-hilbert-curve
class ThirtySix extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1422135090654687237?s=20';

  static const _d = 750.0;

  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    s2q(_d);
    // Flip coordinate space vertically to let (0, 0) be the bottom left corner.
    c.translate(0, _d);
    c.scale(1, -1);

    // Max smooth (real time) order is 7 (n=128). Current cam only handles 5.
    const D = 9, order = 5;
    final n = pow(2, order) ~/ 1, l = n * n;

    final repeat = l * 5 ~/ 8, rd = repeat / l;
    // Perfect loop duration is rd * 4 * D.
    t /= 4;
    t += rd / 3;

    final progress = t / D % rd + rd, lp = l * progress;
    final sw = 256 / n, s = (_d - sw) / (n - 1);
    final p = Path()..moveTo(sw / 2, sw / 2);

    Offset pos(int i, int n) {
      final c = _hni2cc(i % repeat, n);
      final pos = Offset(c.x * s + sw / 2, c.y * s + sw / 2);
      final offset = Offset(s * 24, s * 24) * (i ~/ repeat / 1);
      return pos + offset;
    }

    void line(Offset o) => p.lineTo(o.dx, o.dy);

    // Draw the Hilbert curve up to a certain node based on time.
    for (var i = 0; i < lp; i++) {
      line(pos(i, n));
    }
    // Animate the curve path going to the next node until we reach it.
    final origin = pos(lp.floor(), n), target = pos(lp.ceil(), n);
    final segmentProgress = lp - lp.floor();
    final tip = Offset.lerp(origin, target, segmentProgress)!;

    // Adjust the camera frame.
    c.translate(_d / 1.85, _d / 3.33);
    c.scale(1.15);
    final cam = Curves.linear.transform(lp / repeat % 1) + lp ~/ repeat;
    c.translate(-s * 24 * cam, -s * 24 * cam);

    // Not all of these assignments need to happen every frame, but we are
    // performant enough (:
    const col = Color(0xffffffff);
    final pathPaint = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = sw;
    final segPaint = Paint()
      ..color = Color.lerp(const Color(0xfff00000), col, segmentProgress)!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = sw;

    c.drawPath(p, pathPaint);
    c.drawLine(origin, tip, segPaint);
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
