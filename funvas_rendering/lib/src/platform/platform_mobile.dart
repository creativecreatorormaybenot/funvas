import 'dart:async';

//import 'package:image_gallery_saver/image_gallery_saver.dart' as igs;

FutureOr<void> $downloadBytes(List<int> bytes, String filename) async {
  /* await igs.ImageGallerySaver.saveImage(
    Uint8List.fromList(bytes),
    quality: 100,
    name: filename,
  ); */
  throw UnsupportedError('Cannot download files on this platform.');
}

Future<void> $downloadUrl(
    Uri url, String? filename, Map<String, String>? headers) {
  /* final completer = Completer<void>();
  runZonedGuarded<Future<void>>(
    () => io.HttpClient().getUrl(url).then<io.HttpClientResponse>((request) {
      headers?.forEach(request.headers.add);
      return request.close();
    }).then<void>((response) async {
      final bytes = await response.expand<int>((e) => e).toList();
      await $downloadBytes(bytes, filename ?? url.pathSegments.last);
      completer.complete();
    }).catchError(completer.completeError),
    completer.completeError,
  );
  return completer.future; */
  throw UnsupportedError('Cannot download files on this platform.');
}
