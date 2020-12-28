import 'package:funvas_demo/factories/factory.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

final funvasFactories = <FunvasFactory>[
  FunvasFactory(() => One()),
  FunvasFactory(() => Three()),
  FunvasFactory(() => Four()),
  FunvasFactory(() => Two()),
  FunvasFactory(() => Six()),
  FunvasFactory(() => Five()),
];
