import 'dart:async' show FutureOr;
import 'dart:io' as io show Platform, exit;

import 'platform_mobile.dart' as mobile;

FutureOr<void> $downloadBytes(List<int> bytes, String filename) =>
    io.Platform.isAndroid || io.Platform.isIOS
        ? mobile.$downloadBytes(bytes, filename)
        : throw UnsupportedError('Cannot download files on this platform.');

Future<void> $downloadUrl(
        Uri url, String? filename, Map<String, String>? headers) =>
    io.Platform.isAndroid || io.Platform.isIOS
        ? mobile.$downloadUrl(url, filename, headers)
        : throw UnsupportedError('Cannot download files on this platform.');

void $exit() => io.exit(0);
