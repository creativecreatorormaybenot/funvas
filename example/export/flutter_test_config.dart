import 'dart:async';

// Ignoring because this is only a dev_dependency and the actual example does
// run with sound null safety.
// Issue for golden_toolkit null safety can be found here: https://github.com/eBay/flutter_glove_box/issues/90
// ignore: import_of_legacy_library_into_null_safe
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  await testMain();
}
