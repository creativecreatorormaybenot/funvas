// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert' show base64Encode;
import 'dart:html' show AnchorElement, HttpRequest, document;
import 'dart:typed_data' show ByteBuffer;

import '../config.dart';

FutureOr<void> $downloadBytes(List<int> bytes, String filename) {
  // Encode our file in base64
  final base64 = base64Encode(bytes);
  final stringBuffer = StringBuffer('data:application/octet-stream;')
    ..write('base64,')
    ..write(base64);

  // Create the link with the file
  // add the name
  final anchor = AnchorElement(href: stringBuffer.toString())
    ..target = 'blank'
    ..download = filename.replaceAll('/', '_').replaceAll(r'\', '_');

  // trigger download
  document.body?.append(anchor);

  anchor
    ..click()
    ..remove();
}

Future<void> $downloadUrl(
    Uri url, String? filename, Map<String, String>? headers) {
  final completer = Completer<void>();
  runZonedGuarded<void>(
    () {
      final xhr = HttpRequest()
        ..open('GET', '$url', async: true)
        ..responseType = 'arraybuffer' // 'blob'
        ..withCredentials = false;
      headers?.forEach(xhr.setRequestHeader);

      xhr
        // ignore: unawaited_futures
        ..onLoad.first.then((_) {
          xhr.status == 200
              ? completer.complete(
                  $downloadBytes((xhr.response as ByteBuffer).asUint8List(),
                      filename ?? url.pathSegments.last),
                )
              : completer.completeError(
                  UnsupportedError(
                      'XMLHttpRequest error with status ${xhr.statusText}'),
                  StackTrace.current,
                );
        })
        // ignore: unawaited_futures
        ..onError.first.then((_) {
          // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
          // specific information about the error itself.
          completer.completeError(
            UnsupportedError('XMLHttpRequest error.'),
            StackTrace.current,
          );
        })
        ..send();
    },
    completer.completeError,
  );

  return completer.future;
}

Config $getConfig() => _ConfigWeb();

void $exit() => document.window?.close();

class _ConfigWeb implements Config {
  const _ConfigWeb._();
  static _ConfigWeb? _instance;
  factory _ConfigWeb() => _instance ??= const _ConfigWeb._();

  @override
  final int fps = 14;

  @override
  final int animationDuration = 4;

  @override
  final int dimensions = 512;
}
