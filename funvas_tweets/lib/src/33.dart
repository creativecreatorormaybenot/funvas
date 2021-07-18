import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

class ThirtyThree extends Funvas {
  final noise = OpenSimplex2F(42);

  @override
  void u(double t) {
    const period = 11;
    t %= period;

    // Measured to fit exactly into the size (Roboto Mono).
    const size = 750.0;
    const fontSize = 7.5;
    const startMargin = 1.5;
    const columns = 166;
    const rows = 75;

    const text = 'open_simplex_2';
    String char(int x, int y) {
      final index = (y * columns + x) % text.length;
      return '${text.substring(index, index + 1)}'
          '${x == columns - 1 ? '\n' : ''}';
    }

    s2q(size);
    final bs = GoogleFonts.robotoMono(fontSize: fontSize);
    const color = Color(0xffffffff);
    TextStyle style(int x, int y) {
      final z = sin(t / period * pi * 2);
      final w = cos(t / period * pi * 2);
      final value = noise.noise4Classic(
        x / 99,
        y * columns / rows / 99 + 42,
        z,
        w,
      );
      return bs.copyWith(color: color.withOpacity(1 / 2 + 1 / 2 * value));
    }

    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    c.translate(size / 2, size / 2);
    c.scale(2 - cos(t / period * 2 * pi));
    c.translate(-size / 2, -size / 2);

    final spans = [
      for (var i = 0; i < rows; i++)
        for (var j = 0; j < columns; j++)
          TextSpan(text: char(j, i), style: style(j, i)),
    ];
    TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(c, const Offset(startMargin, 0));

    // Code for debugging the noise + zoom (runs at 60 FPS in real time).
    // for (var x = 0; x < columns; x++) {
    //   for (var y = 0; y < rows; y++) {
    //     c.drawRect(
    //       Rect.fromLTWH(x / columns * 750, y / rows * 750, 1 / columns * 750,
    //           1 / rows * 750),
    //       Paint()..color = style(x, y).color!,
    //     );
    //   }
    // }
  }
}
