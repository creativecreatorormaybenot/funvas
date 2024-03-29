import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:funvas_gallery/factories/animations.dart';
import 'package:funvas_gallery/factories/drawer.dart';
import 'package:funvas_gallery/widgets/page.dart';
import 'package:funvas_gallery/widgets/wrapper.dart';

class GalleryRouterDelegate extends RouterDelegate<int> with ChangeNotifier {
  /// The funvas keys in the order of the stack, where the last key is the
  /// currently displayed animation.
  final _keys = <int>[];

  @override
  int? get currentConfiguration => _keys.isEmpty ? null : _keys.last;

  @override
  Future<bool> popRoute() {
    if (_keys.length < 2) return SynchronousFuture(false);

    _keys.removeLast();
    FunvasDrawer.instance.syncIndex(currentConfiguration!);
    notifyListeners();
    return SynchronousFuture(true);
  }

  @override
  Future<void> setNewRoutePath(int configuration) {
    _keys.add(configuration);
    FunvasDrawer.instance.syncIndex(currentConfiguration!);
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          opaque: true,
          builder: (context) {
            return DebugWrapper(
              child: GalleryPage(
                funvasKey: currentConfiguration ?? FunvasDrawer.instance.key,
                onNext: () {
                  _keys.add(FunvasDrawer.instance.next());
                  notifyListeners();
                },
                onPrevious: () {
                  _keys.add(FunvasDrawer.instance.previous());
                  notifyListeners();
                },
                onShuffle: () {
                  _keys.add(FunvasDrawer.instance.shuffle());
                  notifyListeners();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class GalleryRouteInformationParser extends RouteInformationParser<int> {
  @override
  Future<int> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    final pathSegments = uri.pathSegments;

    if (pathSegments.length != 1) return FunvasDrawer.instance.key;

    final key = int.tryParse(pathSegments.first);
    if (key == null || !funvasFactories.containsKey(key)) {
      return FunvasDrawer.instance.key;
    }
    return key;
  }

  @override
  RouteInformation? restoreRouteInformation(int configuration) {
    return RouteInformation(
      uri: Uri.parse('/$configuration'),
    );
  }
}
