import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';

class FortyNine extends Funvas {
  @override
  void u(double t) {
    const period = 6;
    const factor = 1.75;
    const n = 5e3;

    t %= period;

    const d = 750.0;
    s2q(d);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    c.translate(d / 2, d / 2);
    c.scale(1 / 2);
    c.rotate(-pi / 2);

    Offset oo(int i) => Offset.fromDirection(
          S(i * pi / factor + t / (period * factor * 4) * pi * 2) * pi * 2,
          d / n * (n - i) / 1.25,
        );

    for (var i = 0; i < n; i++) {
      final o = oo(i), no = oo(i + 1);
      final p = Path()
        ..moveTo(no.dx, no.dy)
        ..lineTo(o.dx, o.dy);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..blendMode = BlendMode.plus
        ..strokeWidth = 3
        ..color = HSVColor.fromAHSV(1 / 4, 360 / n * i, 3 / 4, 3 / 4).toColor();

      c.drawPath(p, paint);
    }
  }
}
