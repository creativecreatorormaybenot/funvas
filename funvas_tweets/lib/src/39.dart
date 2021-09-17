import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

/// Remix of https://www.dwitter.net/d/17835, original idea by pavel.
class ThirtyNine extends Funvas {
  @override
  void u(double t, [bool recurse = true]) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    const d = 1500.0;
    s2q(d);

    c.translate(d / 2, d / 2);

    final paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..color = const Color(0xffffffff);

    final p = 1 - (t / 11 + 1 / 2) % 1;
    _draw(d, t, Curves.easeIn.transform((1 - p) % 1), paint);
    _draw(d, t, Curves.easeIn.transform(p), paint);
  }

  void _draw(double d, double t, double p, Paint paint) {
    void f(double X, double Y, double w) {
      if (X * X + Y * Y <= d * 3e3 * p) {
        if (w < 10) return;
        f(X, Y, w /= 2);
        f(X + w, Y, w);
        f(X, Y + w, w);
        f(X + w, Y + w, w);
      } else {
        c.drawRect(Rect.fromLTWH(X, Y, w, w), paint);
      }
    }

    for (var i = 0; i < 4; i++) {
      c.save();
      c.rotate(pi / 2 * i);
      c.scale(.5);
      f(0, 0, d);
      c.restore();
    }
  }
}
