import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/_matchers_io.dart';
import 'package:funvas/src/painter.dart';
import 'package:funvas_tweets/funvas_tweets.dart';
import 'package:funvas_tweets/src/13.dart';

void main() async {
  const fps = 50;
  const animationDuration = Duration(seconds: 10);
  const dimensions = Size(750, 750);
  // If you use a different animation name, you will have to also consider that
  // when exporting to GIF.
  const animationName = 'animation';
  // Using a callback so that the constructor is run inside of the test.
  final funvasFactory = () => Fourteen();

  late final ValueNotifier<double> time;

  setUpAll(() {
    // Allow using HTTP calls.
    HttpOverrides.global = null;
    time = ValueNotifier<double>(0);
  });

  tearDownAll(() {
    time.dispose();
  });

  testWidgets('export funvas animation', (tester) async {
    // Using runAsync to enable using HTTP calls (e.g. for loading images).
    await tester.runAsync(() async {
      await tester.binding.setSurfaceSize(dimensions);
      tester.binding.window.physicalSizeTestValue = dimensions;
      tester.binding.window.devicePixelRatioTestValue = 1;

      final funvas = funvasFactory();

      await tester.pumpWidget(SizedBox.fromSize(
        size: dimensions,
        child: CustomPaint(
          painter: FunvasPainter(
            time: time,
            delegate: funvas,
          ),
        ),
      ));
    });

    final microseconds = animationDuration.inMicroseconds,
        goldensNeeded = fps * (microseconds / 1e6) ~/ 1;

    final fileNameWidth = (goldensNeeded - 1).toString().length;

    for (var i = 0; i < goldensNeeded; i++) {
      time.value = microseconds / goldensNeeded * i / 1e6;
      await tester.pump();

      final matcher = MatchesGoldenFile.forStringPath(
          '$animationName/${'$i'.padLeft(fileNameWidth, '0')}'
          '.png',
          null);
      await matcher.matchAsync(find.byType(SizedBox));
    }
  }, timeout: Timeout(const Duration(hours: 1)));
}
