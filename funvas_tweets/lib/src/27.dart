import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:google_fonts/google_fonts.dart';

class TwentySeven extends Funvas {
  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(Color(0xff000000), BlendMode.srcOver);
    c.translate(d / 2, d / 2);

    t %= 20;
    final int n;
    if (t < 2) {
      n = 3;
    } else if (t < 3) {
      n = 4;
    } else if (t < 5) {
      n = 5;
    } else if (t < 8) {
      n = 6;
    } else if (t < 9) {
      n = 7;
    } else if (t < 10) {
      n = 8;
    } else if (t < 12) {
      n = 16;
    } else if (t < 18) {
      n = 32;
    } else if (t < 19) {
      n = 256;
    } else if (t < 19.25) {
      n = 64;
    } else if (t < 19.5) {
      n = 16;
    } else {
      n = 6;
    }

    drawN(n, d);
    drawFrame(t, d, 1 / 5, n, true);
    drawBlur(t, d, n);
    drawFrame(t, d, 1, n, false);
  }

  void drawBlur(double t, double d, int n) {
    const bd = 0.1, bn = 20;
    for (var i = 1; i < bn; i++) {
      drawFrame(t - bd / bn * i, d, 1 / bn, n, false);
    }
  }

  void drawFrame(double t, double d, double alpha, int n, bool dp) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final shift = pi * i / n * 3;
      final st = t * pi / 2;
      final p = (sin((st + shift) * 2) + 1) / 2;

      final margin = d / 11;
      final distance = d / 11 * 4;
      final r = 10.0;

      final center = Offset.fromDirection(
        pi * 2 / n * i,
        distance * p + margin,
      );
      final color = HSVColor.fromAHSV(alpha, 360 / n * i, 1, 1);

      if (i == 0) {
        path.moveTo(center.dx, center.dy);
      } else {
        path.lineTo(center.dx, center.dy);
      }
      if (!dp) {
        c.drawCircle(center, r, Paint()..color = color.toColor());
      }
    }
    if (dp) {
      c.drawPath(
        path,
        Paint()
          ..color = const Color(0xffffffff).withAlpha(alpha * 255 ~/ 1)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void drawN(int n, double d) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'n = $n',
        style: GoogleFonts.roboto(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: d / 32,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    painter.paint(c, Offset(-painter.width / 2, -painter.height / 2));
  }
}
