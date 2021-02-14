import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Fifteen extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1360867891906830336?s=20';

  static const _depth = 11;
  late double _angle;

  @override
  void u(double t) {
    c.drawPaint(Paint()..color = const Color(0xfff0d9b5));

    _angle = pi / 2 * _cochleoidX(-pi + 2 * pi * (t % 5) / 5);

    final s = s2q(750), d = s.width;
    _branch(d / 2, Offset(d / 2, d), 0, _depth);
  }

  double _cochleoidX(double t) {
    if (t == 0) return 1;
    return (sin(t) * cos(t)) / t;
  }

  void _branch(double d1, Offset p1, double angle, int depth) {
    if (depth == 0) return;
    // Half branch distance.
    final d2 = d1 * 2 / 3;
    final p2 = Offset(
      p1.dx + sin(angle) * d2,
      p1.dy - cos(angle) * d2,
    );
    // Stroke based on depth.
    final paint = Paint()
      ..color = const Color(0xddb58863)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = depth / _depth * 6;
    c.drawLine(p1, p2, paint);

    // Branch left.
    _branch(d2, p2, angle - _angle, depth - 1);
    // Branch right.
    _branch(d2, p2, angle + _angle, depth - 1);
  }
}
