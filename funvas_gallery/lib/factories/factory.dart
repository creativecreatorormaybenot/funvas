import 'package:funvas/funvas.dart';

/// A factory wrapper that instantiates a [T] funvas and caches the result.
class FunvasFactory<T extends Funvas> {
  FunvasFactory(this.factory);

  final T Function() factory;

  /// The cached funvas instance of the factory.
  T get funvas {
    return _funvas ?? (_funvas = factory());
  }

  T? _funvas;
}
