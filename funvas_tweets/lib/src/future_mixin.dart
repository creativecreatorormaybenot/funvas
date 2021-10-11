import 'package:funvas/funvas.dart';

/// Mixin that exposes a [future] that has to complete before the funvas can
/// properly play.
mixin FunvasFutureMixin on Funvas {
  /// Future that has to complete before the funvas can be properly played back.
  Future get future;
}
