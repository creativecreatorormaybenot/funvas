import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

/// You can trace the full origin of this code from the linked tweet, however,
/// I want to point out more clearly that the algorithm for this came from
/// vinca initially and not from me. You an follow the remix origin of my dweet
/// at https://www.dwitter.net/d/14681 in order to see the JavaScript origin
/// of the code, even before I migrated it to Dart initially.
class Five extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1328721811907948544?s=20';

  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;
    c.drawPaint(Paint()..color = const Color(0xffffffff));

    for (var A = .0, q = 123, j = .0, i = 756;
        i-- > 0;
        c.drawRect(
      Rect.fromLTWH(w / 2 + A * sin(j), h / 2 + A * cos(j), i / 84, i / 84),
      Paint()..color = Color.fromRGBO(i % 99 + 156, q - i % q, q, 1),
    )) {
      j = i / 9;
      A = (9 * sin(t * j / 20) + cos(20 * j) + 6) * 21;
    }
  }
}
