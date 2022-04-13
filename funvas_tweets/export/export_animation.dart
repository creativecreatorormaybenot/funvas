import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/src/_matchers_io.dart';
import 'package:funvas/src/painter.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

void main() {
  const fps = 50;
  const animationDuration = Duration(seconds: 6);
  const dimensions = Size(750, 750);
  // If you use a different animation name, you will have to also consider that
  // when exporting to GIF.
  const animationName = 'animation';
  // Using a callback so that the constructor is run inside of the test.
  Funvas funvasFactory() => FortyNine();

  late final ValueNotifier<double> time;

  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.flutter.io/path_provider')
      // Allow google_fonts to download fonts to this directory during tests.
      .setMockMethodCallHandler((call) async => 'export/google_fonts');

  setUpAll(() {
    // Allow using HTTP calls.
    HttpOverrides.global = null;
    time = ValueNotifier<double>(0);
  });

  tearDownAll(() {
    time.dispose();
  });

  Future<void> pumpFunvas(WidgetTester tester) async {
    // Using runAsync to enable using HTTP calls (e.g. for loading images).
    await tester.runAsync(() async {
      await tester.binding.setSurfaceSize(dimensions);
      tester.binding.window.physicalSizeTestValue = dimensions;
      tester.binding.window.devicePixelRatioTestValue = 1;

      final funvas = funvasFactory();
      if (funvas is FunvasFutureMixin) {
        await funvas.future;
      }

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
  }

  testWidgets('trigger google_fonts preload', (tester) async {
    await pumpFunvas(tester);
    await tester.pump();
    await MatchesGoldenFile.forStringPath('$animationName/_warmup.png', null)
        .matchAsync(find.byType(SizedBox));
  });

  testWidgets('export funvas animation', (tester) async {
    await pumpFunvas(tester);

    final microseconds = animationDuration.inMicroseconds,
        goldensNeeded = fps * (microseconds / 1e6) ~/ 1;

    final fileNameWidth = (goldensNeeded - 1).toString().length;

    final watch = Stopwatch()..start();
    for (var i = 0; i < goldensNeeded; i++) {
      time.value = microseconds / goldensNeeded * i / 1e6;
      await tester.pump();

      final matcher = MatchesGoldenFile.forStringPath(
          '$animationName/${'$i'.padLeft(fileNameWidth, '0')}'
          '.png',
          null);
      await matcher.matchAsync(find.byType(SizedBox));

      final frame = i + 1;
      final elapsedTime = watch.elapsed;
      final estimatedRemaining = Duration(
          microseconds:
              elapsedTime.inMicroseconds ~/ frame * (goldensNeeded - frame));
      // ignore: avoid_print
      print('$frame/$goldensNeeded, $elapsedTime, -$estimatedRemaining');
    }
    watch.stop();
  }, timeout: const Timeout(Duration(hours: 3)));
}
