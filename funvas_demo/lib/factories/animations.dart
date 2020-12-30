import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

final funvasFactories = <FunvasFactory<FunvasTweetMixin>>[
  FunvasFactory(() => Three()),
  FunvasFactory(() => Four()),
  FunvasFactory(() => One()),
  FunvasFactory(() => Two()),
  FunvasFactory(() => Six()),
  FunvasFactory(() => Five()),
  FunvasFactory(() => Ten()),
];

/// Funvas factory for a WIP funvas that has no associated tweet yet.
///
/// This one is viewable in debug mode only.
final wipFunvas = FunvasFactory<Funvas>(() => Ten());
