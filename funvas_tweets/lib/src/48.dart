import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

class FortyEight extends Funvas {
  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    const d = 750.0, r = d / 2.1;
    s2q(d);
    c.translate(d / 2, d / 2);
    const n = 42;
    for (var i = 0; i < n; i++) {
      c.rotate(2 * pi / n);
      _drawStreak(t, r, 5, i / n);
    }
  }

  void _drawStreak(double t, double r, double pr, double offset) {
    const n = 9;
    const delay = 0.2;
    for (var i = n; i >= 0; i--) {
      _drawParticle(
        t - delay / n * i,
        r,
        5 / (1 + i / n / 2),
        offset,
        1 - i / n,
      );
    }
  }

  void _drawParticle(double t, double r, double pr, double offset, double o) {
    c.drawCircle(
      Offset(r / 2 + r / 2 * S(1 / 2 + 1 / 2 * C(t + 2 * pi * offset)), 0),
      pr,
      Paint()..color = const Color(0xffffffff).withOpacity(o),
    );
  }
}
