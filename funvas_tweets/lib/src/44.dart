import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

/// Animation inspired by https://www.dwitter.net/d/21012.
///
/// The code still has some golfing artifacts.
class FortyFour extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1444288546609770506?s=20';

  @override
  void u(double t) {
    const d = 750.0, n = 1420 / 2;
    t *= (2 * pi) / 5;
    t %= 2 * pi;

    s2q(d);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    for (var i = 0.0; i < n; i++) {
      c.save();
      c.translate(d / 2, d / 2);
      c.scale(11.2, 11.2);
      c.rotate(i / n * pi * 2);

      drawPart(i, t / 2, 0xffff0000);
      drawPart(i, t / 2 - 1 / 50, 0xff00ff00);
      drawPart(i, t / 2 - 2 / 50, 0xff0000ff);
      c.restore();
    }
  }

  void drawPart(double i, double t, int color) {
    var a = i + t * 4;
    var w = C(a) * 2;
    c.drawOval(
      Rect.fromLTWH(
        20 + 9 * S(a),
        -C(i + t) * S(t) * 12,
        w,
        w > 0 ? 2 : 0,
      ),
      Paint()
        ..blendMode = BlendMode.plus
        ..color = Color(0xffffffff & color),
    );
  }
}
