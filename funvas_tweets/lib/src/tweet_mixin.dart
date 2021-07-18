import 'package:funvas/funvas.dart';

/// Mixin that adds the tweet URLs to [Funvas] animations in this package.
mixin FunvasTweetMixin on Funvas {
  /// The URL to the tweet the funvas animation was created for.
  String get tweet;

  /// Link to the creation process of the funvas animation.
  String? get creationProcess => null;
}
