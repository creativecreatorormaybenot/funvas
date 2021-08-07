import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

class ThirtyEight extends Funvas {
  ThirtyEight() {
    _loadImage();
  }

  static const _d = 750.0, _ps = 15, _duration = 5.0, _n = 42;

  static const _particleProvider = ResizeImage(
    NetworkImage('https://emojigraph.org/media/microsoft/sparkles_2728.png'),
    width: _ps,
    height: _ps,
  );

  Image? _particle;

  double? _pt;
  late double _it;

  @override
  void u(double t) {
    if (_particle == null) {
      return;
    }

    final pt = _pt;
    if (pt == null || pt > t) {
      _init(_pt = t);
      _advance(t, t - _it);
    } else {
      _advance(t - pt, t - _it);
      _pt = t;
    }

    _draw();
  }

  Future<void> _loadImage() async {
    final completer = Completer<Image>();
    final listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
    });

    final stream = _particleProvider.resolve(const ImageConfiguration())
      ..addListener(listener);
    _particle = await completer.future;
    stream.removeListener(listener);
  }

  final _noise = OpenSimplex2S(42);
  final _particles = <_Particle>[];

  void _init(double t) {
    _particles.clear();
    _it = t;
    _particles.add(_Particle.basedOnTime(t, _duration, _noise));
  }

  void _advance(double dt, double t) {
    if (dt <= 0) return;

    for (final particle in _particles) {
      particle.advance(dt, _d);
    }
    _particles.removeWhere((element) => element.oob(_d, _ps / 1));

    if (_particles.length < _n) {
      _particles.add(_Particle.basedOnTime(t, _duration, _noise));
    }
  }

  void _draw() {
    s2q(_d);
    c.translate(_d / 2, _d / 2);

    c.drawAtlas(
      _particle!,
      [
        for (final particle in _particles)
          RSTransform.fromComponents(
            rotation: 0,
            scale: 1,
            anchorX: 0,
            anchorY: 0,
            translateX: particle.p.dx,
            translateY: particle.p.dy,
          ),
      ],
      List.filled(
        _particles.length,
        const Rect.fromLTWH(0, 0, _ps / 1, _ps / 1),
      ),
      null,
      null,
      const Rect.fromLTWH(-_d / 2, -_d / 2, _d, _d),
      Paint(),
    );
  }
}

class _Particle {
  _Particle(this.v);

  factory _Particle.basedOnTime(double t, double D, OpenSimplex2 noise) {
    final tp = t / D % 1 * pi * 2;

    final pn = noise.noise2(sin(tp), cos(tp));
    final vn = noise.noise2(4.2 + cos(tp), sin(tp) - 4.2);
    return _Particle(Offset.fromDirection(pi + pn * pi, 1.5 + vn));
  }

  final Offset v;

  /// Position of the particle relative to the center (0, 0).
  var p = Offset.zero;

  void advance(double dt, double d) {
    p += v * dt * d / 2;
  }

  bool oob(double d, double s) {
    final dx = p.dx.abs(), dy = p.dy.abs();
    if (dx - s / 2 > d / 2) return true;
    if (dy - s / 2 > d / 2) return true;
    return false;
  }
}
