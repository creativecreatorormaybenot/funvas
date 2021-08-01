import 'dart:ui';

import 'package:flutter/foundation.dart';
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

    const n = 32, s = 9.0;
    final p = Path()..moveTo(s, s);
    for (var i = 0; i < n * n; i++) {
      final c = _hni2cc(i, n);
      p.lineTo(c.x * s + s, c.y * s + s);
    }

    final paint = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s / 3;
    c.drawPath(p, paint);
  }
}

/// Transforms the given node index [i] on a pseudo Hilbert curve of order
/// `n -1` to a Cartesian coordinate (Hilbert node index to Cartesian
/// coordinate).
_Coordinate _hni2cc(int i, int n) {
  // The fixed positions of the first order Hilbert curve (n=2).
  const n2positions = [
    _Coordinate(0, 0),
    _Coordinate(0, 1),
    _Coordinate(1, 1),
    _Coordinate(1, 0),
  ];

  final node = n2positions[_l2b(i)];
  var x = node.x, y = node.y;

  var j = i >> 2;

  for (var q = 4; q <= n; q *= 2) {
    final r = q ~/ 2;

    switch (_l2b(j)) {
      case 0:
        var tx = x;
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
      case 4:
        var ty = y;
        y = (r - 1) - x;
        x = (r - 2) - ty;
        x += r;
        break;
    }

    j >>= 2;
  }
  return _Coordinate(x, y);
}

/// Returns the last two bits of the given integer [x].
///
/// With can simply do this using bitwise AND and `b011` (which is decimal `3`).
int _l2b(int x) => x & /*int.parse('11', radix: 2)*/ 3;

@immutable
class _Coordinate {
  const _Coordinate(this.x, this.y);

  final int x, y;
}
