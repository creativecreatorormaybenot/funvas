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
    const n = 5;
    for (var i = 0; i < n; i++) {
      _drawWheel(t + 2 * pi / n * i, r);
    }
  }

  void _drawWheel(double t, double r) {
    c.save();
    const n = 42;
    for (var i = 0; i < n; i++) {
      c.rotate(2 * pi / n);
      _drawStreak(t, r, 5, i / n);
    }
    c.restore();
  }

  void _drawStreak(double t, double r, double pr, double offset) {
    const n = 9;
    const delay = 0.4;
    const opacity = 0xaa / 0xff;
    for (var i = n; i >= 0; i--) {
      final lt = t - delay / n * i;
      final lo = opacity * (1 - 1 / n * i);

      _drawParticle(
        lt,
        r,
        pr,
        offset,
        const Color(0xffff0000).withOpacity(lo),
      );
      _drawParticle(
        lt - delay / 8,
        r,
        pr,
        offset,
        const Color(0xff00ff00).withOpacity(lo),
      );
      _drawParticle(
        lt - delay / 4,
        r,
        pr,
        offset,
        const Color(0xff0000ff).withOpacity(lo),
      );
    }
  }

  void _drawParticle(
    double t,
    double r,
    double pr,
    double offset,
    Color color,
  ) {
    c.drawCircle(
      Offset(r / 2 + r / 2 * S(1 / 2 + 1 / 2 * C(t + 2 * pi * offset)), 0),
      pr,
      Paint()
        ..color = color
        ..blendMode = BlendMode.screen,
    );
  }
}
