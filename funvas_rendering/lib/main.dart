import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_rendering/src/platform.dart';
import 'package:funvas_tweets/funvas_tweets.dart';
import 'package:path/path.dart' as p;

import 'src/config.dart';

final Config _config = Platform.getConfig();
final int _fps = _config.fps;
final Duration _animationDuration =
    Duration(seconds: _config.animationDuration);
final Size _dimensions = Size.square(_config.dimensions.toDouble());
// If you use a different animation name, you will have to also consider that
// when assembling the animation using ffmpeg.
const String _animationName = 'animation'; // TODO: FROM ENVIRONMENT
// The path to the directory where the animation will be saved.
const String _exportPath = 'export'; // TODO: FROM ENVIRONMENT

// TODO: FROM ENVIRONMENT
// Using a callback so that the constructor is executed after initializing the
// binding.
Funvas funvasFactory() => Four();

Future<void> main() async {
  _RenderingFlutterBinding.ensureInitialized();

  final time = ValueNotifier(.0);
  final funvas = funvasFactory();
  if (funvas is FunvasFutureMixin) await funvas.future;
  final rootWidget = SizedBox.fromSize(
    size: _dimensions,
    child: CustomPaint(
      painter: FunvasPainter(
        time: time,
        delegate: funvas,
      ),
    ),
  );

  _RenderingFlutterBinding.instance
    ..setSurfaceSize(_dimensions)
    ..attachRootWidget(rootWidget)
    // Schedule and render a warm-up frame.
    ..scheduleWarmUpFrame()
    ..handleBeginFrame(Duration.zero)
    ..handleDrawFrame();
  await _renderFrame();

  final microseconds = _animationDuration.inMicroseconds,
      framesToRender = _fps * (microseconds / 1e6) ~/ 1;

  final clock = Stopwatch()..start();
  final futures = <Future>[];
  for (var i = 0; i < framesToRender; i++) {
    time.value = microseconds / framesToRender * i / 1e6;

    // Render the funvas animation / frame in the render view.
    _RenderingFlutterBinding.instance
      ..scheduleFrame()
      ..handleBeginFrame(clock.elapsed)
      ..handleDrawFrame();

    final image = await _renderFrame();
    final frame = i + 1;
    // We parallelize the saving of the rendered frames by running the futures
    // in parallel.
    futures.add(_exportFrame(image, clock, framesToRender, frame));

    final elapsedTime = clock.elapsed;
    final estimatedRemaining = Duration(
        microseconds:
            elapsedTime.inMicroseconds ~/ frame * (framesToRender - frame));
    print('[r] $frame/$framesToRender, $elapsedTime, -$estimatedRemaining');
  }

  await Future.wait<void>(futures);
  time.dispose();
  clock.stop();
  Platform.exit();
}

Future<ui.Image> _renderFrame() {
  final renderView = _RenderingFlutterBinding.instance.renderView;
  return renderView.layer.toImage(renderView.paintBounds);
}

Future<void> _exportFrame(
    ui.Image image, Stopwatch clock, int framesToRender, int frame) async {
  final bytes = await image.clone().toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (bytes == null) throw StateError('Could not export frame $frame.');

  final fileNameWidth = (framesToRender - 1).toString().length;
  final fileName = '${'${frame - 1}'.padLeft(fileNameWidth, '0')}.png';
  final filePath = p.join(_exportPath, _animationName, fileName);
  await Platform.downloadBytes(bytes.buffer.asUint8List(), filePath);
  final elapsedTime = clock.elapsed;
  final estimatedRemaining = Duration(
      microseconds:
          elapsedTime.inMicroseconds ~/ frame * (framesToRender - frame));
  print('[e] $frame/$framesToRender, $elapsedTime, -$estimatedRemaining');
}

/// Binding implementation specifically tailored to rendering animations.
///
/// This binding allows setting the surface size of the root [RenderView] and
/// inserts an [_ExposedRenderView] for converting the rendered root to images.
class _RenderingFlutterBinding extends BindingBase
    with
        SchedulerBinding,
        ServicesBinding,
        GestureBinding,
        SemanticsBinding,
        RendererBinding,
        PaintingBinding,
        WidgetsBinding {
  static _RenderingFlutterBinding? _instance;
  static _RenderingFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);

  static _RenderingFlutterBinding ensureInitialized() {
    if (_RenderingFlutterBinding._instance == null) {
      _RenderingFlutterBinding();
    }
    return _RenderingFlutterBinding.instance;
  }

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  Size? _surfaceSize;

  void setSurfaceSize(Size? size) {
    if (_surfaceSize == size) return;
    _surfaceSize = size;
    handleMetricsChanged();
  }

  @override
  ViewConfiguration createViewConfiguration() {
    return ViewConfiguration(
      size: _surfaceSize ?? _dimensions,
      devicePixelRatio: 1,
    );
  }

  @override
  void initRenderView() {
    renderView = _ExposedRenderView(
      configuration: createViewConfiguration(),
      window: window,
    );
    renderView.prepareInitialFrame();
  }

  @override
  _ExposedRenderView get renderView => super.renderView as _ExposedRenderView;
}

/// Render view implementation that exposes the [layer] as an [OffsetLayer]
/// for converting to images at the root level.
class _ExposedRenderView extends RenderView {
  _ExposedRenderView({
    RenderBox? child,
    required ViewConfiguration configuration,
    required ui.FlutterView window,
  }) : super(child: child, configuration: configuration, window: window);

  // Unprotect the layer getter.
  @override
  OffsetLayer get layer => super.layer as OffsetLayer;
}
