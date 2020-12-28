import 'dart:math';

import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/animations.dart';
import 'package:funvas_demo/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

/// Handler for drawing funvas animations.
///
/// This will by default return the [funvasFactories] in default order, however,
/// the order can be [shuffle]d.
///
/// The drawer also takes care of not only drawing from the factories but also
/// returning the [Funvas] instances right away. This is done using the `[]`
/// operator.
class FunvasDrawer {
  FunvasDrawer._()
      : _factories = funvasFactories,
        _random = Random();

  /// Global funvas drawer instance.
  static final instance = FunvasDrawer._();

  final List<FunvasFactory<FunvasTweetMixin>> _factories;
  final Random _random;

  void shuffle() {
    if (_factories.length < 2) return;

    final first = _factories.first;
    // Shuffle the list until the first element is different.
    // The reason we want to do this is because we show the first element after
    // shuffling and we want to have a visual change :)
    while (identical(first, _factories.first)) {
      _factories.shuffle(_random);
    }
  }

  /// Draws a [Funvas] with a [FunvasTweetMixin] from the collection of funvas
  /// animations and returns a cached instance.
  ///
  /// The [index] can wrap around, i.e. modulo the list length is used for
  /// accessing the elements.
  FunvasTweetMixin operator [](int index) {
    return _factories[index % _factories.length].funvas;
  }
}
