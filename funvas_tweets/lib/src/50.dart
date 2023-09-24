import 'dart:async';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/future_mixin.dart';

class Fifty extends Funvas with FunvasFutureMixin {
  Fifty() {
    _init();
  }

  final _completer = Completer<FragmentProgram>();
  FragmentProgram? _fragmentProgram;

  @override
  Future get future => _completer.future;

  Future<void> _init() async {
    _completer.complete(_fragmentProgram = await FragmentProgram.fromAsset(
      'packages/funvas_tweets/shaders/50.frag',
    ));
  }

  @override
  void u(double t) {
    final fragmentProgram = _fragmentProgram;
    if (fragmentProgram == null) return;

    final shader = fragmentProgram.fragmentShader();
    shader.setFloat(0, x.width);
    shader.setFloat(1, x.height);
    shader.setFloat(2, t);
    c.drawRect(Offset.zero & x.size, Paint()..shader = shader);
  }
}
