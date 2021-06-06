import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

final funvasFactories = <FunvasFactory<FunvasTweetMixin>>[
  FunvasFactory(() => TwentyFour()),
  FunvasFactory(() => Three()),
  FunvasFactory(() => Four()),
  FunvasFactory(() => Fifteen()),
  FunvasFactory(() => Twelve()),
  FunvasFactory(() => TwentyThree()),
  FunvasFactory(() => One()),
  FunvasFactory(() => TwentySeven()),
  FunvasFactory(() => Eleven()),
  FunvasFactory(() => Thirteen()),
  FunvasFactory(() => Sixteen()),
  FunvasFactory(() => Seventeen()),
  FunvasFactory(() => Six()),
  FunvasFactory(() => Fourteen()),
  FunvasFactory(() => Eighteen()),
  FunvasFactory(() => Nineteen()),
  FunvasFactory(() => TwentyTwo()),
];

/// Funvas factory for a WIP funvas that does not need to have an associated
/// tweet yet.
///
/// This one is viewable in debug mode only.
final wipFunvas = FunvasFactory<Funvas>(() => TwentyEight());
