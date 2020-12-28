import 'package:funvas_tweets/funvas_tweets.dart';

/// A factory wrapper that instantiates a [FunvasTweetMixin] funvas and caches
/// the result.
class FunvasFactory {
  FunvasFactory(this.factory);

  final FunvasTweetMixin Function() factory;

  /// The cached funvas instance of the factory.
  FunvasTweetMixin get funvas {
    return _funvas ?? (_funvas = factory());
  }

  FunvasTweetMixin? _funvas;
}
