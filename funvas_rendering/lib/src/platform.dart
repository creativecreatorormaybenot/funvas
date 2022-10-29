import 'dart:async';

import 'package:meta/meta.dart';

import 'platform/platform_io.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'platform/platform_web.dart';

@sealed
abstract class Platform {
  Platform._();

  /// Downloads the given [bytes] to the given [filename].
  static FutureOr<void> downloadBytes(List<int> bytes, String filename) =>
      $downloadBytes(bytes, filename);

  /// Downloads the given [url] to the given [filename] with the given [headers].
  static Future<void> downloadUrl(Uri url,
          {String? filename, Map<String, String>? headers}) =>
      $downloadUrl(url, filename, headers);

  static void exit() => $exit();
}
