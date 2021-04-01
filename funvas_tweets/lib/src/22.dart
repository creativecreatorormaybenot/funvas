import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class TwentyTwo extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1370328227479191553?s=20';

  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;

    final sideLength = 150.0,
        diameter = sideLength / cos(pi / 6),
        radius = diameter / 2,
        height = radius + radius * sin(pi / 6);
    final rotation = ((t / 5 % 1) * pi * 2 + pi / 6) % (pi * 2);

    void drawTriangles(Color color) {
      for (var i = 0; i < w / sideLength + 1; i++) {
        for (var j = 0; j < h / height + 2; j++) {
          var x = i * sideLength, y = j * height, angle = rotation;
          if (j % 2 != 0) {
            x += sideLength / 2;
          }

          if (rotation >= pi * 5 / 3) {
            x -= sideLength / 2;
            angle += pi;
            y += radius / 2;
          } else if (rotation >= pi * 4 / 3) {
            x -= sideLength / 2;
            y -= radius / 2;
          } else if (rotation >= pi) {
            angle += pi;
          } else if (rotation >= pi * 2 / 3) {
            y -= radius;
          } else if (rotation >= pi * 1 / 3) {
            angle += pi;
            x -= sideLength / 2;
            y -= radius / 2;
          }

          _drawTriangle(
            center: Offset(x, y),
            rotation: angle,
            paint: Paint()..color = color,
            radius: radius,
          );
        }
      }
    }

    const light = Color(0xffffeac6), dark = Color(0xffa47752);
    if ((rotation % (pi * 2 / 3)) < pi * 1 / 3) {
      c.drawColor(dark, BlendMode.srcOver);
      drawTriangles(light);
    } else {
      c.drawColor(light, BlendMode.srcOver);
      drawTriangles(dark);
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
