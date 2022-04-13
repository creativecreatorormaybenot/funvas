import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';

class FortyNine extends Funvas {
  @override
  void u(double t) {
    const d = 750.0;
    s2q(d);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    c.translate(d / 2, d / 2);
    c.rotate(pi * t / 9 * 2);

    const n = 3e3;
    Offset oo(int i) => Offset.fromDirection(
          S(i + t / 9).abs() * pi * 2,
          d / n * (n - i) / 1.25,
        );

    c.rotate(-t / 9 * pi * 2 - pi / 2);
    for (var i = 0; i < n; i++) {
      final o = oo(i), no = oo(i + 1);
      final p = Path()
        ..moveTo(o.dx, o.dy)
        ..lineTo(no.dx, no.dy);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..blendMode = BlendMode.plus
        ..color = HSVColor.fromAHSV(1, 360 / n * i, 3 / 4, 3 / 4).toColor();

      if (p.computeMetrics().first.length > 420) continue;
      c.drawPath(p, paint);
    }
  }
}
