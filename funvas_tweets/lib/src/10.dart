import 'dart:async';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

class Ten extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1344066533417484291?s=20';

  @override
  String get creationProcess => 'https://youtu.be/7DC_ZcqMOUk';

  Ten() {
    _loadImage(_soProvider).then((value) => _soImage = value);
    _loadImage(_ghProvider).then((value) => _ghImage = value);
  }

  /// [ImageProvider] for my StackOverflow avatar image.
  late final _soProvider = const ResizeImage(
    NetworkImage('https://www.gravatar.com/avatar/'
        '260caa996ae8ac9fcee35487aa8d7c81?s=420&d=identicon&r=PG&f=1'),
    width: 420,
    height: 420,
  );

  /// [ImageProvider] for my GitHub avatar image.
  late final _ghProvider = const ResizeImage(
    NetworkImage('https://avatars3.githubusercontent.com/u/19204050?s=245&v=4'),
    width: 245,
    height: 245,
  );

  Image? _soImage, _ghImage;

  Future<Image> _loadImage(ImageProvider provider) async {
    final completer = Completer<Image>();
    final listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
    });

    final stream = provider.resolve(const ImageConfiguration())
      ..addListener(listener);
    final result = await completer.future;
    stream.removeListener(listener);
    return result;
  }

  @override
  void u(double t) {
    final s = s2q(420), w = s.width, h = s.height;

    // White background.
    c.drawPaint(Paint()..color = const Color(0xffffffff));

    // The whole animation should be 7 seconds long and then repeat every 7s.
    t %= 7;

    if (_soImage == null || _ghImage == null) {
      // Loading images.
      return;
    }
    final soCenter =
        Offset((w - _soImage!.width) / 2, (h - _soImage!.height) / 2);
    const blur = 11.0;
    final ghCenter =
        Offset((w - _ghImage!.width) / 2, (h - _ghImage!.height) / 2);

    final soPaint = Paint(), ghPaint = Paint();
    final Offset soPosition, ghPosition;

    if (t < 1) {
      // Fly in the GH avatar in the first second.
      soPosition = soCenter - Offset(w, 0);
      ghPosition = ghCenter - Offset(w - w * Curves.ease.transform(t), 0);
    } else if (t < 2) {
      // Fly out the GH avatar again in the second second.
      soPosition = soCenter - Offset(w, 0);
      ghPosition = ghCenter + Offset(w * Curves.ease.transform(t - 1), 0);
    } else if (t < 3) {
      // Fly in the SO avatar in the third second.
      soPosition = soCenter - Offset(0, h - h * Curves.ease.transform(t - 2));
      ghPosition = ghCenter - Offset(w, 0);
    } else if (t < 4) {
      // Fly the GH avatar in again. Now, with the blend mode applied.
      soPosition = soCenter;
      ghPaint.blendMode = BlendMode.difference;
      ghPosition = ghCenter + Offset(w * (1 - Curves.ease.transform(t - 3)), 0);
    } else if (t < 5) {
      // Blur the SO avatar in the background.
      final sigma = Curves.decelerate.transform(t - 4) * blur;
      soPaint.imageFilter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
      soPosition = soCenter;
      ghPaint.blendMode = BlendMode.difference;
      ghPosition = ghCenter;
    } else if (t < 6) {
      // Do not do animate anything.
      soPaint.imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
      ghPaint.blendMode = BlendMode.difference;
      soPosition = soCenter;
      ghPosition = ghCenter;
    } else {
      // Fly out both avatars again in the last second.
      assert(t < 7);
      soPaint.imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
      ghPaint.blendMode = BlendMode.difference;
      final progress = Curves.easeIn.transform(t - 6) * 1.1;
      soPosition = soCenter + Offset(0, h * progress);
      ghPosition = ghCenter - Offset(w * progress, 0);
    }

    c.drawImage(_soImage!, soPosition, soPaint);
    c.drawImage(_ghImage!, ghPosition, ghPaint);
  }
}
