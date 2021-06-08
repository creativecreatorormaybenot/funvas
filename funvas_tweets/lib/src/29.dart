import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class TwentyNine extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1402203754036871169?s=20';

  static const _pointsN = 420, _pN = 5;
  static const double _pointDiameter = 15, _frameDimension = 750;

  late final List<Path> _paths = <Path>[_cp, _sp, _cp, _hxp, _hrp, _tp];
  late final _points = [for (final path in _paths) _pointsFromPath(path)];

  @override
  void u(double t) {
    final d = s2q(_frameDimension).width;
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    c.translate(d / 2, d / 2);
    t += 4.5;
    t *= 1.5;

    final p1 = _points[(t ~/ 3 - 1) % _paths.length];
    final p2 = _points[(t ~/ 3) % _paths.length];

    final progress = (t % 3) / 3;
    for (var i = 0; i < _pN; i++) {
      _drawPoints(p1, p2, _ms.transform(min(1, progress + i / 80)), i);
    }
  }

  void _drawPoints(List<Offset> p1, List<Offset> p2, double progress, int i) {
    final points = [
      for (var i = 0; i < _pointsN; i++) Offset.lerp(p1[i], p2[i], progress)!,
    ];

    c.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color =
            HSVColor.fromAHSV(min(1, 1.5 / _pN), 360 / _pN * i, 1, 1).toColor()
        // We want to draw circles.
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _pointDiameter
        ..blendMode = BlendMode.plus,
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
        curve: Curves.fastOutSlowIn,
      )),
      weight: 9,
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
