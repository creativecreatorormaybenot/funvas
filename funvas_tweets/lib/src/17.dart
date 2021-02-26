import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

/// Rotating dots connected by lines.
///
/// Mostly inspired by https://www.reddit.com/r/oddlysatisfying/comments/lqnj0c/dots_spiraling_out_in_a_nice_loop.
class Seventeen extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1365335653823754245?s=20';

  @override
  void u(double t) {
    c.drawPaint(Paint()..color = const Color(0xffdddddd));
    c.saveLayer(Offset.zero & Size(x.width, x.height), Paint());
    c.drawPaint(Paint()..color = const Color(0xffffffff));

    final d = s2q(750).width;
    const r = 7.0, n = 42;

    Offset position(int i) {
      return (Offset.zero & Size.square(d)).center +
          Offset.fromDirection(
            t * pi * 2 * (n - i) / n,
            d / 2 / (n + 1) * (i + 1),
          );
    }

    Paint paint(int i, [bool difference = true]) {
      return Paint()
        ..color = HSVColor.fromAHSV(
          1,
          360 * i / n,
          1,
          1,
        ).toColor()
        ..strokeWidth = 2
        ..blendMode = difference ? BlendMode.xor : BlendMode.srcOver;
    }

    for (var i = 0; i < n; i++) {
      final p2 = position(i);
      if (i != 0) {
        final p1 = position(i - 1);
        c.drawPath(
          Path()
            ..moveTo(d / 2, d / 2)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close(),
          paint(i),
        );
      }
      c.drawCircle(p2, r, paint(i));
    }

    for (var i = 0; i < n; i++) {
      c.drawCircle(position(i), r, paint(i, false));
    }

    c.restore();
  }
}
