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
    for (var i = .0; i < n; i++) {
      c.drawCircle(
        Offset.fromDirection(
          S(i + t / 9).abs() * pi * 2,
          d / n * (n - i) / 1.25,
        ),
        5,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = HSVColor.fromAHSV(1, 360 / n * i, 3 / 4, 3 / 4).toColor(),
      );
    }
  }
}
