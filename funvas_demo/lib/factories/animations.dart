import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

final funvasFactories = <int, FunvasFactory<FunvasTweetMixin>>{
  30: FunvasFactory(() => Thirty()),
  29: FunvasFactory(() => TwentyNine()),
  24: FunvasFactory(() => TwentyFour()),
  3: FunvasFactory(() => Three()),
  4: FunvasFactory(() => Four()),
  15: FunvasFactory(() => Fifteen()),
  12: FunvasFactory(() => Twelve()),
  23: FunvasFactory(() => TwentyThree()),
  23: FunvasFactory(() => ThirtyOne()),
  1: FunvasFactory(() => One()),
  27: FunvasFactory(() => TwentySeven()),
  11: FunvasFactory(() => Eleven()),
  13: FunvasFactory(() => Thirteen()),
  16: FunvasFactory(() => Sixteen()),
  17: FunvasFactory(() => Seventeen()),
  6: FunvasFactory(() => Six()),
  14: FunvasFactory(() => Fourteen()),
  18: FunvasFactory(() => Eighteen()),
  19: FunvasFactory(() => Nineteen()),
  22: FunvasFactory(() => TwentyTwo()),
};

/// Funvas factory for a WIP funvas that does not need to have an associated
/// tweet yet.
///
/// This one is viewable in debug mode only.
final wipFunvas = FunvasFactory<Funvas>(() => ThirtyOne());
