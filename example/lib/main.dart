import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';

void main() {
  runApp(const ExampleApp());
}

/// Example app demonstrating how to integrate a [Funvas] using a
/// [FunvasContainer].
class ExampleApp extends StatelessWidget {
  /// Constructs [ExampleApp].
  const ExampleApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: FunvasContainer(
              funvas: ExampleFunvas(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example implementation of a funvas.
///
/// It uses a very simple [Canvas.drawCircle] operation to create an animation.
class ExampleFunvas extends Funvas {
  @override
  void u(double t) {
    c.drawCircle(
      Offset(x.width / 2, x.height / 2),
      S(t).abs() * x.height / 4 + 42,
      Paint()..color = R(C(t) * 255, 42, 60 + T(t)),
    );
  }
}
