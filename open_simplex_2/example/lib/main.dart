import 'dart:math';

import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

void main() {
  runApp(const ExampleApp());
}

/// Example app showcasing how to use the `open_simplex_2` package.
class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'open_simplex_2 example',
      home: Scaffold(
        body: SizedBox.expand(
          child: FunvasContainer(
            funvas: _OpenSimplex2Funvas(),
          ),
        ),
      ),
    );
  }
}

/// Example funvas using the `open_simplex_2` package.
///
/// The code is ported from one of  Etienne Jacob's tutorials on his personal
/// website (https://bleuje.github.io/tutorial3/).
/// You can find it here: https://gist.githubusercontent.com/Bleuje/0ee88547c273b6ae49ae69527c13e611/raw/a28fb770ab6586a11cda227c44af0ac57f45e8d7/tuto3_entirecode.pde.
class _OpenSimplex2Funvas extends Funvas {
  final noise = OpenSimplex2F(12345);

  @override
  void u(double t) {
    s2q(100);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);

    const m = 90;
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        final x = 100 * i / (m - 1);
        final y = 100 * j / (m - 1);

        final dx = 20.0 * periodicFunction(t - offset(x, y), 0, x, y);
        final dy = 20.0 * periodicFunction(t - offset(x, y), 123, x, y);

        c.drawCircle(
          Offset(x + dx, y + dy),
          0.5,
          Paint()
            ..color = const Color.fromARGB(50, 255, 255, 255),
        );
      }
    }
  }

  double periodicFunction(double p, double seed, double x, double y) {
    const radius = 1.3;
    const scl = 0.018;
    return noise.noise4Classic(
      seed + radius * cos(2 * pi * p),
      radius * sin(2 * pi * p),
      scl * x,
      scl * y,
    );
  }

  double offset(double x, double y) {
    return 0.015 * sqrt(pow(50 - x, 2) + pow(50 - y, 2));
  }
}
