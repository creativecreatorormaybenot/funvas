import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

class TwentyOne extends Funvas {
  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;

    final sideLength = 150.0,
        diameter = sideLength / cos(pi / 6),
        radius = diameter / 2,
        height = radius + radius * sin(pi / 6);
    final rotation = Curves.slowMiddle.transform(t / 4 % 1) * pi * 4 / 3;

    void drawTriangles(Color color, bool shift) {
      for (var i = 0; i < w / sideLength + 1; i++) {
        for (var j = 0; j < h / height + 1; j++) {
          var x = i * sideLength, y = j * height;
          if (j % 2 != 0) {
            x += sideLength / 2;
          }
          if (shift) {
            x -= sideLength / 2;
            y += radius / 2;
          }

          _drawTriangle(
            center: Offset(x, y),
            rotation: rotation + (shift ? pi : 0),
            paint: Paint()..color = color,
            radius: radius,
          );
        }
      }
    }

    const light = Color(0xfff0d9b5), dark = Color(0xffb58863);
    if (rotation < pi * 2 / 3) {
      c.drawColor(dark, BlendMode.srcOver);
      drawTriangles(light, true);
    } else {
      c.drawColor(light, BlendMode.srcOver);
      drawTriangles(dark, false);
    }
  }

  void _drawTriangle({
    required Offset center,
    required double rotation,
    required Paint paint,
    required double radius,
  }) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(rotation);

    final vertices = <Offset>[];
    for (var i = 0; i < 3; i++) {
      final angle = 2 * pi / 3 * (i - 1 / 2) + pi / 6;
      vertices.add(Offset(
        radius * cos(angle),
        radius * sin(angle),
      ));
    }
    c.drawPath(
      Path()..addPolygon(vertices, true),
      paint,
    );
    c.restore();
  }
}
