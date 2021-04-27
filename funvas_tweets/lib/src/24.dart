import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';

class TwentyFour extends Funvas {
  static const _start = -pi / 3, _end = pi * 6, _n = 200;

  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);

    t %= _end - _start;
    t += _start;

    final bp = Paint()
      ..color = const Color(0xff000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var y = d / 5;
    c.drawLine(Offset(0, y), Offset(d, y), bp);
    drawCircle(Offset(0, y), d / 16, t, 4, bp..strokeWidth = 2);
    c.translate(0, y);
    c.scale(1, -1);
    c.translate(0, -y);
    drawCircle(Offset(0, y), d / 8, t - pi * 3 / 4, 8, bp);
    c.translate(0, y);
    c.scale(1, -1);
    c.translate(0, -y);

    y = d / 14 * 9;
    c.drawLine(Offset(0, y), Offset(d, y), bp..strokeWidth = 1);
    drawCircle(Offset(0, y), d / 12, t - pi, 16, bp..strokeWidth = 2);
    c.translate(0, y);
    c.scale(1, -1);
    c.translate(0, -y);
    drawCircle(Offset(0, y), d / 6, t - pi * 3, 32, bp);
    c.translate(0, y);
    c.scale(1, -1);
    c.translate(0, -y);
  }

  void drawCircle(Offset center, double radius, double t, int n, Paint paint) {
    final s = center + Offset(0, -radius);

    Offset cc(t) => s + Offset(t * radius, 0);
    c.drawCircle(cc(t), radius, paint);

    for (var i = 0.0; i < pi * 2; i += pi * 2 / n) {
      drawPath(
        (t) => cc(t) + Offset(cos(t + i) * radius, sin(t + i) * radius),
        radius,
        t,
        HSLColor.fromAHSL(1, i / 2 / pi * 360, .7, .5).toColor(),
      );
    }
  }

  void drawPath(
      Offset Function(double t) v, double radius, double t, Color color) {
    c.drawCircle(v(t), 5, Paint()..color = color);

    final start = v(_start);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = _start; i < t; i += (_end - _start) / _n) {
      final p = v(i);
      path.lineTo(p.dx, p.dy);
    }
    final end = v(t);
    path.lineTo(end.dx, end.dy);
    c.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }
}
