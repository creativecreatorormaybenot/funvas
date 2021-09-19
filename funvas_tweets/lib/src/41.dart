import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class FortyOne extends Funvas with FunvasTweetMixin {
  @override
  String get tweet => 'https://twitter.com/creativemaybeno';

  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    const d = 500.0;
    s2q(d);
    c.translate(d / 2, d / 2);

    _drawChromaticWheel(-t / 4, 35, 125, -99);
    _drawChromaticWheel(t / 2, 45, 45, 42);
  }

  void _drawChromaticWheel(double p, double r, double d, double td) {
    _drawWheel(p, r, d, 0xffff0000);
    _drawWheel(p - 1 / td, r, d, 0xff00ff00);
    _drawWheel(p - 1 / td * 2, r, d, 0xff0000ff);
  }

  void _drawWheel(double p, double r, double d, int color) {
    c.save();
    c.rotate(pi * p * 2);

    final a = -p * pi * 2;
    final lp = Path(), tp = Path();
    void atv(double x, double y) {
      final o = Offset(x, y);
      final vertices = [
        Offset.fromDirection(-pi / 2 + a, r) + o,
        Offset.fromDirection(pi * 2 / 3 - pi / 2 + a, r) + o,
        Offset.fromDirection(pi * 4 / 3 - pi / 2 + a, r) + o,
      ];
      for (final vertex in vertices) {
        lp.moveTo(0, 0);
        lp.lineTo(vertex.dx, vertex.dy);
      }
      tp.addPolygon(vertices, false);
    }

    atv(0, d);
    atv(-d * _sqrt3 / 2, -d / 2);
    atv(d * _sqrt3 / 2, -d / 2);

    c.drawPath(
      lp,
      Paint()
        ..color = Color(0xddffffff & color)
        ..style = PaintingStyle.stroke
        ..blendMode = BlendMode.screen
        ..strokeWidth = 1,
    );
    c.drawPath(
      tp,
      Paint()
        ..color = Color(0xffffffff & color)
        ..blendMode = BlendMode.screen,
    );
    c.restore();
  }
}

final _sqrt3 = sqrt(3);
