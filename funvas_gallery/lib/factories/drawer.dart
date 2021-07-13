import 'dart:math';

import 'package:funvas/funvas.dart';
import 'package:funvas_gallery/factories/animations.dart';
import 'package:funvas_gallery/factories/factory.dart';
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
        _keys = funvasFactories.keys.toList(),
        _random = Random();

  /// Global funvas drawer instance.
  static final instance = FunvasDrawer._();

  final Map<int, FunvasFactory<FunvasTweetMixin>> _factories;
  final List<int> _keys;
  final Random _random;

  var _index = 0;

  int get key => _keys[_index % _keys.length];

  /// Shuffles the order of the keys internally and returns the first key.
  int shuffle() {
    _index = 0;
    final first = _keys.first;
    // Shuffle the list until the first element is different.
    // The reason we want to do this is because we show the first element after
    // shuffling and we want to have a visual change :)
    while (identical(first, _keys.first)) {
      _keys.shuffle(_random);
    }

    return key;
  }

  /// Goes to the next funvas internally and returns its key.
  int next() {
    _index++;
    return key;
  }

  int previous() {
    _index--;
    return key;
  }

  void syncIndex(int key) {
    _index = _keys.indexOf(key);
  }

  /// Draws a [Funvas] with a [FunvasTweetMixin] from the collection of funvas
  /// animations and returns a cached instance.
  FunvasTweetMixin operator [](int key) {
    return _factories[key]!.funvas;
  }
}
