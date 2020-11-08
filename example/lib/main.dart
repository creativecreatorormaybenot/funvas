import 'dart:ui';

import 'package:example/tweets/tweets.dart';
import 'package:example/viewer.dart';
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

  /// List of example funvas implementations.
  static final examples = <Funvas>[
    ExampleFunvas(),
    WaveFunvas(),
    OrbsFunvas(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('creativecreatorormaybenot Funvas'),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Examples'),
                Tab(text: '@creativemaybeno tweets'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FunvasViewer(funvases: ExampleApp.examples),
              FunvasViewer(funvases: creativecreatorormaybenotTweets),
            ],
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

/// Funvas adapted 1:1 from https://www.dwitter.net/d/3713.
class WaveFunvas extends Funvas {
  @override
  void u(double t) {
    c.scale(x.width / 1920, x.height / 1080);

    for (var i = 0; i < 64; i++) {
      c.drawRect(
        Rect.fromLTWH(
          i * 30.0,
          400 + C(4 * t + (i * 3)) * 100,
          27,
          200,
        ),
        Paint(),
      );
    }
  }
}

/// Funvas adapted 1:1 from https://www.dwitter.net/d/4342.
class OrbsFunvas extends Funvas {
  @override
  void u(double t) {
    c.scale(x.width / 1920, x.height / 1080);

    final v = t + 400;
    for (var q = 255; q > 0; q--) {
      final paint = Paint()..color = R(q, q, q);
      c.drawCircle(
          Offset(
            1920 / 2 + C(v - q) * (v + q),
            540 + S(v - q) * (v - q),
          ),
          40,
          paint);
    }
  }
}
