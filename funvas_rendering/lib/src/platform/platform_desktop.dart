import 'dart:async' show FutureOr;
import 'dart:io' as io;

FutureOr<void> $downloadBytes(List<int> bytes, String filename) async {
  final file = io.File(filename);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}

Future<void> $downloadUrl(
        Uri url, String? filename, Map<String, String>? headers) =>
    throw UnsupportedError('Cannot download files on this platform.');
