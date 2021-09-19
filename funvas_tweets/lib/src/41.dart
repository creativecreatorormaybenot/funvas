import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

class FortyOne extends Funvas {
  @override
  void u(double t) {
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);
    const d = 750.0;
    final tt = t / 2.5;
    s2q(d);
    c.translate(d / 2, d / 2);

    _drawWheel(tt / 4, 55, 215);
    _drawWheel(-tt / 2, 50, 125);
    _drawWheel(tt, 45, 45);
  }

  void _drawWheel(double p, double r, double d) {
    c.save();
    c.rotate(pi * p * 2);

    final a = -p * pi * 2;
    final lp = Path(), tp = Path();
    void atv(double x, double y) {
      final o = Offset(x, y);
      final vertices = [
        Offset.fromDirection(-pi / 2 + a, r) + o,
        Offset.fromDirection(pi * 2 / 3 - pi / 2 + a, r) + o,
        Offset.fromDirection(pi * 4 / 3 - pi / 2 + a, r) + o,
      ];
      for (final vertex in vertices) {
        lp.moveTo(0, 0);
        lp.lineTo(vertex.dx, vertex.dy);
      }
      tp.addPolygon(vertices, false);
    }

    atv(0, d);
    atv(-d * _sqrt3 / 2, -d / 2);
    atv(d * _sqrt3 / 2, -d / 2);

    c.drawPath(
      lp,
      Paint()
        ..color = const Color(0xff000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    c.drawPath(tp, Paint()..color = const Color(0xff000000));
    c.restore();
  }
}

final _sqrt3 = sqrt(3);
