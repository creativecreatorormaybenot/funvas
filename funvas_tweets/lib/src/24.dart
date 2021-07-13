import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class TwentyFour extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1392781785302544384?s=20';

  /// Length of each path segment.
  ///
  /// Lower values will deliver greater fidelity but decreased performance.
  /// I think that `0.1` or lower delivers good results but going for `0.09`
  /// for safety :) `0.2` makes it visibly choppy around the corners (the large
  /// almost semi circles).
  ///
  /// For an export to GIF, I would use a way lower value to ensure best
  /// possible quality, but for the gallery `0.01` should be good enough.
  static const _l = 9e-2;

  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);

    t += 1;
    t /= 8 / 6;
    t %= 6;

    c.translate(d / 2, d / 2);
    c.rotate(-(t / 3 * pi) % (2 * pi));
    c.translate(-d / 2, -d / 2);

    final r = d / 10.5;
    drawTrack(t, (d - r * 2 * pi) / 2, d / 2, r, 12, -15);
  }

  void drawTrack(double t, double x, double y, double r, int n, [int co = 0]) {
    final bp = Paint()
      ..color = const Color(0xff000000)
      ..strokeWidth = 1.5
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
        HSLColor.fromAHSL(1, (i / 2 / pi * 360 + co) % 360, 3 / 4, 1 / 2)
            .toColor();

    final oc = t - 3 * pi;

    for (var i = 0.0; i < pi * 2; i += pi * 2 / n) {
      drawPath(v(i), radius, t, oc, l(i));
    }

    c.drawCircle(cc(t), radius, paint);
    c.drawCircle(cc(oc), radius, paint);
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
        ..blendMode = BlendMode.srcOver
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }
}
