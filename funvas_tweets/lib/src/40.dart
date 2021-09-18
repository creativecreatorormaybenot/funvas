import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

/// Animation inspired by https://www.dwitter.net/d/20460 by pavel.
///
/// The code is fully novel, only the idea is inspired by the dweet.
class Forty extends Funvas {
  @override
  void u(double t) {
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);
    const d = 750.0;
    s2q(d);

    const r = 50.0;
    const vLim = d + r;
    final hLim = d + r * _sqrt3 / 2;

    final paint = Paint();
    var y = .0, alt = false;
    do {
      for (var x = alt ? .0 : _sqrt3 * r / 2; x <= hLim; x += _sqrt3 * r) {
        _RegularHexagon(x, y, r * S(t + x + y).abs() + 1).draw(c, paint);
      }
      alt = !alt;
      y += r * 3 / 2;
    } while (y <= vLim);
  }
}

final _sqrt3 = sqrt(3);

class _RegularHexagon {
  _RegularHexagon(this.x, this.y, this.radius) : assert(radius > 0) {
    _init();
  }

  final double x, y;
  final double radius;

  Path get path => _path;
  late final Path _path;

  void _init() {
    final points = <Offset>[];

    for (var i = 0; i < 6; i++) {
      final angle = pi / 3 * i + pi / 2;

      points.add(Offset(
        x + radius * cos(angle),
        y + radius * sin(angle),
      ));
    }

    _path = Path()..addPolygon(points, true);
  }

  void draw(Canvas canvas, Paint paint) {
    canvas.drawPath(_path, paint);
  }
}
