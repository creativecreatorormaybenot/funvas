import 'package:funvas/funvas.dart';
import 'package:funvas_gallery/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

final funvasFactories = <int, FunvasFactory<FunvasTweetMixin>>{
  24: FunvasFactory(() => TwentyFour()),
  32: FunvasFactory(() => ThirtyTwo()),
  30: FunvasFactory(() => Thirty()),
  3: FunvasFactory(() => Three()),
  4: FunvasFactory(() => Four()),
  15: FunvasFactory(() => Fifteen()),
  37: FunvasFactory(() => ThirtySeven()),
  12: FunvasFactory(() => Twelve()),
  23: FunvasFactory(() => TwentyThree()),
  42: FunvasFactory(() => FortyTwo()),
  29: FunvasFactory(() => TwentyNine()),
  1: FunvasFactory(() => One()),
  11: FunvasFactory(() => Eleven()),
  13: FunvasFactory(() => Thirteen()),
  16: FunvasFactory(() => Sixteen()),
  17: FunvasFactory(() => Seventeen()),
  14: FunvasFactory(() => Fourteen()),
  43: FunvasFactory(() => FortyThree()),
  19: FunvasFactory(() => Nineteen()),
  22: FunvasFactory(() => TwentyTwo()),
  36: FunvasFactory(() => ThirtySix()),
  34: FunvasFactory(() => ThirtyFour()),
  35: FunvasFactory(() => ThirtyFive()),
  39: FunvasFactory(() => ThirtyNine()),
  40: FunvasFactory(() => Forty()),
  41: FunvasFactory(() => FortyOne()),
};

/// Funvas factory for a WIP funvas that does not need to have an associated
/// tweet yet.
///
/// This one is viewable in debug mode only.
final wipFunvas = FunvasFactory<Funvas>(() => FortyFour());
