import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class ThirtyOne extends Funvas with FunvasTweetMixin {
  @override
  String get tweet => 'https://twitter.com/creativemaybeno';

  static const _depth = 9;

  @override
  void u(double t) {
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);
    final d = s2q(750).width;
    final r = d / 2;
    final s = cos(pi / 6) * r;
    final h = s * sqrt(3);

    t %= 5;

    final center = Offset(d / 2, d / 2 + d / 8);
    c.translate(center.dx, center.dy + h / 12);
    c.scale(1 + Curves.bounceOut.transform(t / 5));
    c.scale(1.2);
    c.translate(-center.dx, -center.dy - h / 12);

    final one = center - Offset(s / 2 + s / 20 * t, h / 2 - h / 40 * t);
    final two = center + Offset(s, -h / 40 * t);
    final three = center + Offset(-s / 2 + s / 20 * t, h / 2 + h / 40 * t);

    _drawTriangle(_Triangle.fromCenter(one, r));
    _drawTriangle(_Triangle.fromCenter(two, r));
    _drawTriangle(_Triangle.fromCenter(three, r));
  }

  void _drawTriangle(
    _Triangle triangle, [
    Color color = const Color(0xff000000),
  ]) {
    triangle.draw(c, Paint()..color = color);
    _draw4(triangle);
  }

  void _draw4(_Triangle triangle, [int depth = 0]) {
    if (depth == _depth) return;

    final sub4 = triangle.sub4();
    sub4.first.draw(c, Paint()..color = const Color(0xffffffff));
    for (final triangle in sub4.sublist(1)) {
      _draw4(triangle, depth + 1);
    }
  }
}

class _Triangle {
  factory _Triangle.fromCenter(Offset center, double r) {
    return _Triangle(
      a: Offset.fromDirection(-pi / 2, r) + center,
      b: Offset.fromDirection(pi * 2 / 3 - pi / 2, r) + center,
      c: Offset.fromDirection(pi * 4 / 3 - pi / 2, r) + center,
    );
  }

  const _Triangle({required this.a, required this.b, required this.c});

  final Offset a, b, c;

  /// Returns the 4 sub triangles in the order of middle first, and then the
  /// other three.
  List<_Triangle> sub4() {
    final bc = b + (c - b) / 2;
    final ba = b + (a - b) / 2;
    final ca = c + (a - c) / 2;

    return [
      _Triangle(a: ca, b: bc, c: ba),
      _Triangle(a: ca, b: a, c: ba),
      _Triangle(a: ba, b: b, c: bc),
      _Triangle(a: bc, b: ca, c: c),
    ];
  }

  void draw(Canvas canvas, Paint paint) {
    canvas.drawPath(
      Path()..addPolygon([a, c, b], true),
      paint,
    );
  }
}
