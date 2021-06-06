import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';

class TwentyEight extends Funvas {
  static const _pointsN = 50000;
  static const double _pointDiameter = 2, _frameDimension = 750;

  @override
  void u(double t) {
    final d = s2q(_frameDimension).width;
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    c.translate(d / 2, d / 2);
    t += 4.5;

    final paths = [_cp, _sp, _cp, _hxp, _hrp, _tp];
    final p1 = _pointsFromPath(paths[(t ~/ 3 - 1) % paths.length]);
    final p2 = _pointsFromPath(paths[(t ~/ 3) % paths.length]);

    final progress = (t % 3) / 3;
    for (var i = 0; i < 6; i++) {
      _drawPoints(p1, p2, _ms.transform(min(1, progress + i / 69)));
    }
  }

  void _drawPoints(List<Offset> p1, List<Offset> p2, double progress) {
    final random = Random(progress * 1e5 ~/ 1);
    final points = [
      for (var i = 0; i < _pointsN; i++)
        Offset.lerp(
          p1[i],
          p2[i],
          min(1, progress + random.nextDouble() * min(progress, .2)),
        )!,
    ];

    c.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = const Color(0xffffffff).withOpacity(min(1, 2e3 / _pointsN))
        // We want to draw circles.
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _pointDiameter,
    );
  }

  List<Offset> _pointsFromPath(Path path) {
    final metric = path.computeMetrics().first;
    final interval = metric.length / _pointsN;
    return <Offset>[
      for (var i = 0; i < _pointsN; i++)
        metric.getTangentForOffset(interval * i)!.position,
    ];
  }

  final _cp = Path()
    ..addOval(
      Rect.fromCircle(center: Offset.zero, radius: _frameDimension / 2.5),
    );
  final _sp = Path()
    ..addRect(
      Rect.fromCircle(center: Offset.zero, radius: _frameDimension / 4),
    );
  final _tp = Path()
    ..addRegularPolygon(
      center: Offset.zero,
      radius: _frameDimension / 3,
      vertices: 3,
    );
  final _hxp = Path()
    ..addRegularPolygon(
      center: Offset.zero,
      radius: _frameDimension / 3.5,
      vertices: 6,
    );
  final _hrp = Path()
    ..moveTo(0, -_frameDimension / 5)
    ..cubicTo(
      _frameDimension / 8,
      -_frameDimension / 2,
      _frameDimension / 1.5,
      -_frameDimension / 8,
      0,
      _frameDimension / 3,
    )
    ..cubicTo(
      -_frameDimension / 1.5,
      -_frameDimension / 8,
      -_frameDimension / 8,
      -_frameDimension / 2,
      0,
      -_frameDimension / 5,
    );

  final _ms = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0, end: 0),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(
        curve: Curves.ease,
      )),
      weight: 2,
    ),
  ]);
}

extension on Path {
  void addRegularPolygon({
    required Offset center,
    required double radius,
    required int vertices,
  }) {
    final points = <Offset>[];
    for (var i = 0; i < vertices; i++) {
      final angle = 2 * pi / vertices * (i - 1 / 2) + pi / 2;
      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }

    addPolygon(points, true);
  }
}
