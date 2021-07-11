import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Thirty extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1414180416760651780?s=20';

  static const _blobCount = 6, _blobSpeed = 5.0;

  // The max resolution is 8190 (min is 1). I have no idea why, but the logic
  // stops working at exactly 8191. I assume this has something to do with the
  // number of colors / stops Gradient.radial can process internally.
  // It might be because we always add 1 more color / stop than the resolution,
  // which means that it stops working at 8192. In binary:
  // * 01111111111111 works (8191).
  // * 10000000000000 does not work (8192).
  // 8190 is 1ffe in hex.
  static const _shaderResolution = 0x400;

  final _blobs = <Blob>[];
  final _colors = <Color>[];
  final _stops = <double>[];

  @override
  void u(double t) {
    final size = s2q(750);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    if (_blobs.isEmpty) {
      final random = Random(4269);
      for (var i = 0; i < _blobCount; i++) {
        _blobs.add(
          Blob(
            offset: Offset(
              random.nextDouble() * size.width,
              random.nextDouble() * size.height,
            ),
            velocity: Offset.fromDirection(
              random.nextDouble() * 2 * pi,
              _blobSpeed,
            ),
          ),
        );
      }
    }

    if (_colors.isEmpty) {
      assert(_stops.isEmpty);
      _colors.addAll([
        for (var i = _shaderResolution; i >= 0; i--)
          Color.fromRGBO(
            0xff,
            0xff,
            0xff,
            const Cubic(1, 1, 0, 1)
                .transform(pow(i / _shaderResolution, 2).toDouble()),
          ),
      ]);
      _stops.addAll([
        for (var i = 0; i < _shaderResolution + 1; i++)
          pow(i / _shaderResolution, 2).toDouble(),
      ]);
    }

    for (final blob in _blobs) {
      final shader = Gradient.radial(
        blob.offset,
        size.longestSide,
        _colors,
        _stops,
        TileMode.clamp,
      );
      c.drawPaint(
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.plus,
      );
    }

    for (final blob in _blobs) {
      blob.move(size);
    }
  }
}

/// Blob as represented by Matthew Carroll in https://youtu.be/Iyh81vS3lFM.
///
/// This code is directly taken from https://github.com/matthew-carroll/flutter_processing/blob/599ebd7fdd3098fd0c4531ce5ca5df0518e10afd/example/lib/the_coding_train/coding_challenges/028_metaballs.dart#L104
/// as the point of this funvas is trying to challenge the FPS.
class Blob {
  Blob({
    required Offset offset,
    required Offset velocity,
  })  : _offset = offset,
        _velocity = velocity;

  Offset get offset => _offset;
  Offset _offset;

  Offset _velocity;

  void move(Size screenSize) {
    if (_offset.dx <= 0 || _offset.dx >= screenSize.width) {
      _velocity = Offset(-_velocity.dx, _velocity.dy);
    }
    if (_offset.dy <= 0 || _offset.dy >= screenSize.height) {
      _velocity = Offset(_velocity.dx, -_velocity.dy);
    }

    _offset += _velocity;
  }
}
