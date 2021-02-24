import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

/// Funvas for a projected 3D rotating cube.
///
/// Found some inspiration for the perspective transforms at https://stackoverflow.com/questions/701504/perspective-projection-determine-the-2d-screen-coordinates-x-y-of-points-in-3/701978#comment32917856_701978
/// and https://github.com/gnomeby/canvas3D/blob/679d2a93bc88e78771ecc32979c0cacd621e396b/canvas-3d-cube.html.
class Sixteen extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1364560611435307008?s=20';

  @override
  void u(double t) {
    c.drawPaint(Paint()..color = const Color(0xff333333));
    final d = s2q(750).width;

    const cube = [
      _Vertex3(-1 / 2, -1 / 2, -1 / 2),
      _Vertex3(-1 / 2, -1 / 2, 1 / 2),
      _Vertex3(1 / 2, -1 / 2, 1 / 2),
      _Vertex3(1 / 2, -1 / 2, -1 / 2),
      _Vertex3(1 / 2, 1 / 2, -1 / 2),
      _Vertex3(1 / 2, 1 / 2, 1 / 2),
      _Vertex3(-1 / 2, 1 / 2, 1 / 2),
      _Vertex3(1 / 2, 1 / 2, 1 / 2),
      _Vertex3(1 / 2, -1 / 2, 1 / 2),
      _Vertex3(-1 / 2, -1 / 2, 1 / 2),
      _Vertex3(-1 / 2, 1 / 2, 1 / 2),
      _Vertex3(-1 / 2, 1 / 2, -1 / 2),
      _Vertex3(1 / 2, 1 / 2, -1 / 2),
      _Vertex3(1 / 2, -1 / 2, -1 / 2),
      _Vertex3(-1 / 2, -1 / 2, -1 / 2),
      _Vertex3(-1 / 2, 1 / 2, -1 / 2),
    ];

    const camera = _Vertex3(0, 0, -3);
    final f = sqrt(pow(camera.x, 2) + pow(camera.y, 2) + pow(camera.z, 2));

    final slowedT = t / 5;
    final sectionedT = slowedT % 2 ~/ 1;

    Offset transform(_Vertex3 vertex) {
      final transformed = Offset(
        ((vertex.x - camera.x) * (f / (vertex.z - camera.z))) + camera.x,
        ((vertex.y - camera.y) * (f / (vertex.z - camera.z))) + camera.y,
      );
      return transformed * d / 2 + Offset(d / 2, d / 2);
    }

    _Vertex3 rotate(_Vertex3 vertex) {
      final radians = Curves.linear.transform(slowedT % 1) * 2 * pi;
      final _Vertex3 preRotated;
      switch (sectionedT) {
        case 0:
          preRotated = _Vertex3(
            vertex.x * cos(radians) + vertex.z * sin(radians),
            vertex.y,
            -vertex.x * sin(radians) + vertex.z * cos(radians),
          );
          break;
        case 1:
          preRotated = _Vertex3(
            vertex.x,
            vertex.y * cos(radians) - vertex.z * sin(radians),
            vertex.y * sin(radians) + vertex.z * cos(radians),
          );
          break;
        default:
          throw UnimplementedError();
      }
      return _Vertex3(
        preRotated.x * cos(radians) - preRotated.y * sin(radians),
        preRotated.x * sin(radians) + preRotated.y * cos(radians),
        preRotated.z,
      );
    }

    final transformedCube = cube.map(rotate).map(transform).toList();
    for (var i = 0; i < transformedCube.length - 1; i++) {
      final p1 = transformedCube[i];
      final p2 = transformedCube[i + 1];
      c.drawLine(
        p1,
        p2,
        Paint()
          ..color = Color(0xffffffff).withRed(i * 222 ~/ transformedCube.length)
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

class _Vertex3 {
  const _Vertex3(this.x, this.y, this.z);

  final double x, y, z;
}
