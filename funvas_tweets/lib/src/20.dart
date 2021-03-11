import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Twenty extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1369754059826212869?s=20';

  @override
  void u(double t) {
    c.save();
    _drawFrame(t);
    c.restore();
    c.saveLayer(
      Offset.zero & Size(x.width, x.height),
      Paint()..blendMode = BlendMode.difference,
    );
    c.save();
    _drawFrame(t + 1 / 3);
    c.restore();
    c.restore();
    c.saveLayer(
      Offset.zero & Size(x.width, x.height),
      Paint()..blendMode = BlendMode.difference,
    );
    c.save();
    _drawFrame(t + 2 / 3);
    c.restore();
    c.restore();
  }

  void _drawFrame(double t) {
    final diagonal = 125.0, side = diagonal / sqrt2;
    final s = s2q(750), w = s.width, h = s.height;
    final rotation = ((t / 4 % 1) + 1 / 4) % 1 * pi;

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
