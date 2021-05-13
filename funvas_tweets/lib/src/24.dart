import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';

class TwentyFour extends Funvas {
  static const _l = 1e-2;

  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);

    final r = d / 20;
    drawTrack(t, r * 3, r * 3, r, 1);
    drawTrack(t + 4 * pi, r * 3, r * 7.75, r, 2);
    drawTrack(t + 2 * pi, r * 3, r * 12.25, r, 3, 90);
    drawTrack(t + 3 * pi, r * 3, r * 17, r, 4, 90);
    // drawTrack(t, d / 8, d / 2, d / 8, 16);
  }

  void drawTrack(double t, double x, double y, double r, int n, [int co = 0]) {
    final bp = Paint()
      ..color = const Color(0xff000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    c.drawLine(Offset(x, y), Offset(x + 2 * pi * r, y), bp);
    drawCircle(
        Offset(x, y), r, (t * pi) % (12 * pi), n, bp..strokeWidth = 2, co);
  }

  void drawCircle(
      Offset center, double radius, double t, int n, Paint paint, int co) {
    final s = center + Offset(0, -radius);

    Offset cc(t) {
      // Every 6 pi, we loop around.
      t %= 6 * pi;
      if (t < 2 * pi) {
        return s + Offset(t * radius, 0);
      } else if (t < 3 * pi) {
        final cp = s + Offset(2 * pi * radius, 0);
        return cp +
            Offset(
              sin(t) * radius,
              radius - cos(t) * radius,
            );
      } else if (t < 5 * pi) {
        return s + Offset(2 * pi * radius - (t - 3 * pi) * radius, radius * 2);
      } else {
        final cp = s + Offset(0, radius * 2);
        return cp +
            Offset(
              sin(t) * radius,
              -radius - cos(t) * radius,
            );
      }
    }

    Offset Function(double t) v(double i) {
      return (double t) {
        return cc(t) + Offset(cos(t + i) * radius, sin(t + i) * radius);
      };
    }

    Color l(double i) =>
        HSLColor.fromAHSL(1, (i / 2 / pi * 360 + co) % 360, .7, .5).toColor();

    final oc = t - 3 * pi;
    c.drawCircle(cc(t), radius, paint);
    c.drawCircle(cc(oc), radius, paint);

    for (var i = 0.0; i < pi * 2; i += pi * 2 / n) {
      drawPath(v(i), radius, t, oc, l(i));
    }
    // Make sure the dots are all on top of the lines.
    for (var i = 0.0; i < pi * 2; i += pi * 2 / n) {
      c.drawCircle(v(i)(t), 5, Paint()..color = l(i));
      c.drawCircle(v(i)(oc), 5, Paint()..color = l(i));
    }
  }

  void drawPath(Offset Function(double t) o, double radius, double t, double s,
      Color color) {
    final start = o(s);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = s; i < t; i += _l) {
      final p = o(i);
      path.lineTo(p.dx, p.dy);
    }
    final end = o(t);
    path.lineTo(end.dx, end.dy);
    c.drawPath(
      path,
      Paint()
        ..color = color
        ..blendMode = BlendMode.multiply
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }
}
