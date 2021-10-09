import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/future_mixin.dart';

class FortyFive extends Funvas with FunvasFutureMixin {
  FortyFive() {
    _loadImage();
  }

  static const _w = 3355, _h = 5000;

  static const _monaLisaProvider = ResizeImage(
    NetworkImage(
      'https://firebasestorage.googleapis.com/v0/b/funvas-cdf8b.appspot.com/o/'
      'mona_lisa.png?alt=media&token=6395033b-e312-4dfe-86d8-d64ed9041860',
    ),
    width: _w,
    height: _h,
  );

  final Completer<Image> _monaLisaCompleter = Completer();
  Image? _monaLisa;

  @override
  Future get future => _monaLisaCompleter.future;

  @override
  void u(double t) {
    final monaLisa = _monaLisa;
    if (monaLisa == null) return;

    const d = 750.0;
    s2q(d);

    // We assume that the height is bigger than the width since we know it is ;)
    const scale = d / _h;
    const scaleFactor = 142;

    const relativeX = 0.4015, relativeY = 0.2293;
    const relativeWidthGap = (_h - _w) / _h / 2;

    final zoom = lerpDouble(
      scaleFactor,
      scaleFactor * scaleFactor,
      Curves.easeInQuint.transform((t + 1 / 7) / 2 % 1),
    )!;
    // The zoom precision determines how many iterations we perform in the
    // integral in order to get a more and more precise zoom location.
    // We could use the loop below that computes the transforms below since it
    // does exactly the same for the translation (which is the zoom location),
    // however, we want more precision, i.e. more iterations here :)
    // Since we never zoom in farther than 4 times, this precision is
    // technically unnecessary, i.e. you do not see it at that zoom level (:
    // So the real reason is that we optimize in the loop below to never draw
    // what you cannot see and that is why the zoom location would jump if we
    // computed it there.
    const zoomPrecision = 11;
    var zoomDx = relativeWidthGap * d, zoomDy = .0;
    for (var i = 0; i < zoomPrecision; i++) {
      final integralScale = scale / pow(scaleFactor, i);

      zoomDx += _w * integralScale * relativeX;
      zoomDy += _h * integralScale * relativeY;
    }

    final monaLisas = <RSTransform>[];

    var monaLisaScale = scale;
    var translateX = .0, translateY = .0;
    do {
      monaLisas.add(RSTransform.fromComponents(
        rotation: 0,
        scale: monaLisaScale,
        anchorX: 0,
        anchorY: 0,
        translateX: translateX,
        translateY: translateY,
      ));

      translateX += _w * monaLisaScale * relativeX;
      translateY += _h * monaLisaScale * relativeY;
      monaLisaScale /= scaleFactor;

      if (monaLisaScale / scaleFactor * zoom * _w > d) {
        // Remove this entry because the one after the next one already covers
        // the whole screen.
        monaLisas.removeLast();
      }
    } // Only draw a Mona Lisa if it takes up at least 1 pixel on the screen.
    while (monaLisaScale * zoom * _h > 1);

    c.translate(zoomDx, zoomDy);
    c.scale(zoom);
    c.translate(-zoomDx + relativeWidthGap * d, -zoomDy);

    c.drawAtlas(
      monaLisa,
      monaLisas,
      [
        for (var i = 0; i < monaLisas.length; i++)
          const Rect.fromLTWH(0, 0, _w / 1, _h / 1),
      ],
      null,
      null,
      null,
      Paint(),
    );
  }

  Future<void> _loadImage() async {
    final listener = ImageStreamListener((info, _) {
      _monaLisaCompleter.complete(info.image);
    });

    final stream = _monaLisaProvider.resolve(const ImageConfiguration())
      ..addListener(listener);
    _monaLisa = await _monaLisaCompleter.future;
    stream.removeListener(listener);
  }
}
