import 'dart:async' show FutureOr;
import 'dart:io' as io show Platform, exit;

import '../config.dart';
import 'platform_desktop.dart' as desktop;
import 'platform_mobile.dart' as mobile;

FutureOr<void> $downloadBytes(List<int> bytes, String filename) =>
    io.Platform.isAndroid || io.Platform.isIOS
        ? mobile.$downloadBytes(bytes, filename)
        : desktop.$downloadBytes(bytes, filename);

Future<void> $downloadUrl(
        Uri url, String? filename, Map<String, String>? headers) =>
    io.Platform.isAndroid || io.Platform.isIOS
        ? mobile.$downloadUrl(url, filename, headers)
        : desktop.$downloadUrl(url, filename, headers);

Config $getConfig() => _ConfigIO();

void $exit() => io.exit(0);

class _ConfigIO implements Config {
  const _ConfigIO._({
    required this.fps,
    required this.animationDuration,
    required this.dimensions,
  });
  static _ConfigIO? _instance;
  factory _ConfigIO() => _instance ??= _ConfigIO._(
        fps: _intFromEnvironment('FPS', 14),
        animationDuration: _intFromEnvironment('DURATION', 4),
        dimensions: _intFromEnvironment('SIZE', 512),
      );

  static int _intFromEnvironment(String key, int defaultValue) {
    final env = io.Platform.environment[key];
    return env != null ? int.tryParse(env) ?? defaultValue : defaultValue;
  }

  @override
  final int fps;

  @override
  final int animationDuration;

  @override
  final int dimensions;
}
