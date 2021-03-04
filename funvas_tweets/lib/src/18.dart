import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:funvas/funvas.dart';

class Eighteen extends Funvas {
  Eighteen() {
    final random = Random();
    _sides = List.generate(_n, (index) => random.nextInt(6) + 3);
  }

  /// The number of sides for the polygons to be drawn.
  ///
  /// The values are chosen randomly but persist between the different phases.
  late final List<int> _sides;

  /// The distances for the polygons from the bottom center.
  static const List<double> _distances = [
    .25,
    .35,
    .56,
    .6,
    .5,
    .6,
    .7,
    .8,
    .9,
  ];

  /// The angle for the polygons travelling the [_distances].
  static const List<double> _angles = [
    -pi / 8,
    pi / 8,
    -pi / 17,
    pi / 21,
    -pi / 5,
    pi / 6,
    -pi / 8,
    pi / 15,
    -pi / 12,
  ];

  static const _n = 9;

  @override
  void u(double t) {
    final s = s2q(750), r = Offset.zero & s;
    c.drawColor(const Color(0xffffc108), BlendMode.srcOver);

    _phase0(t, r);
    return;
    // Looping t that loops every 6 seconds.
    final lt = t % 6;
    if (lt < 2) {
      _phase0(lt, r);
    } else if (lt < 4) {
      _phase1(lt - 2, r);
    } else {
      _phase2(lt - 4, r);
    }
  }

  void _phase0(double t, Rect r) {
    c.drawLine(
      r.bottomCenter + Offset(-r.width / 24, r.height / 15),
      r.bottomCenter + Offset(-r.width / 6, -r.height / 6),
      Paint()
        ..color = const Color(0xff02569b)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    c.drawLine(
      r.bottomCenter + Offset(r.width / 24, r.height / 15),
      r.bottomCenter + Offset(r.width / 6, -r.height / 6),
      Paint()
        ..color = const Color(0xff02569b)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < _n; i++) {
      c.drawRect(
        Rect.fromCircle(
          center: r.bottomCenter +
              Offset.fromDirection(
                _angles[i] - pi / 2,
                _distances[i] * r.shortestSide,
              ),
          radius: 9,
        ),
        Paint()
          ..color = const Color(0xff02569b)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _phase1(double t, Rect r) {}

  void _phase2(double t, Rect r) {}
}
