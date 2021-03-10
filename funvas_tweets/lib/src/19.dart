import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

class Nineteen extends Funvas {
  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;

    final diagonal = 125.0, side = diagonal / sqrt2;
    final rotation =
        -(Curves.bounceInOut.transform(t / 4 % 1) + 1 / 4) % 1 * pi;

    const white = Color(0xffffffff), black = Color(0xff000000);

    void drawSquares(Color color, bool shift) {
      final addend = shift ? 1 / 2 : 0;
      for (var i = 0; i < w / diagonal + 1; i++) {
        for (var j = 0; j < h / diagonal + 1; j++) {
          _drawSquare(
            center: Offset((i + addend) * diagonal, (j + addend) * diagonal),
            rotation: rotation,
            paint: Paint()..color = color,
            sideLength: side,
          );
        }
      }
    }

    if (rotation < pi / 4 || rotation > pi * 3 / 4) {
      _drawBackground(black);
      drawSquares(white, true);
    } else {
      _drawBackground(white);
      drawSquares(black, false);
    }
  }

  void _drawBackground(Color color) {
    c.drawColor(color, BlendMode.srcOver);
  }

  void _drawSquare({
    required Offset center,
    required double rotation,
    required Paint paint,
    required double sideLength,
  }) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rotation);
    c.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: sideLength,
        height: sideLength,
      ),
      paint,
    );
    c.restore();
  }
}
