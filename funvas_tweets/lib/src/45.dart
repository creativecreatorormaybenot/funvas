import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';

class FortyFive extends Funvas {
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

  Image? _monaLisa;

  @override
  void u(double t) {
    final monaLisa = _monaLisa;
    if (monaLisa == null) return;

    const d = 750.0;
    s2q(d);

    const scale = d / _h;
    const scaledH = _h * scale, scaledW = _w * scale;
    const scaleFactor = 142;

    const relativeX = 0.4015, relativeY = 0.2293;
    const relativeWidthGap = (_h - _w) / _h / 2;

    // final zoom = 1 + pow(t / 10 % 1, 4) * 1e3;
    final zoom = 29999.0;
    var zoomDx = relativeWidthGap * d, zoomDy = .0;

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

      zoomDx += _w * monaLisaScale * relativeX;
      zoomDy += _h * monaLisaScale * relativeY;
      translateX += _w * monaLisaScale * relativeX;
      translateY += _h * monaLisaScale * relativeY;
      monaLisaScale /= scaleFactor;

      if (monaLisaScale / scaleFactor * zoom * _w > d) {
        // Remove this entry because the one after the next one already covers
        // the whole screen.
        monaLisas.removeLast();
      }
    } // Only draw a mona lisa if it takes up at least 1 pixel on the screen.
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
    // c.drawRect(Rect.fromLTWH(translateX, translateY, 1, 1),
    //     Paint()..color = Color(0xffff0000));
  }

  Future<void> _loadImage() async {
    final completer = Completer<Image>();
    final listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
    });

    final stream = _monaLisaProvider.resolve(const ImageConfiguration())
      ..addListener(listener);
    _monaLisa = await completer.future;
    stream.removeListener(listener);
  }
}
