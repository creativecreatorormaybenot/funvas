import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_gallery/factories/animations.dart';
import 'package:funvas_gallery/factories/drawer.dart';
import 'package:funvas_gallery/factories/factory.dart';
import 'package:funvas_gallery/widgets/link.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    Key? key,
    required this.funvasKey,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
  }) : super(key: key);

  /// The key to the funvas in [funvasFactories] to retrieve the funvas animation
  /// from the [FunvasDrawer] instance.
  ///
  /// The [FunvasFactory.funvas] getter ensures that we always retrieve a cached
  /// instance.
  final int funvasKey;

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

const _kOverlayTransitionDuration = Duration(milliseconds: 150);

class _GalleryPageState extends State<GalleryPage> {
  var _overlayEnabled = true;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const ScrollIntent(
          direction: AxisDirection.up,
        ),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const ScrollIntent(
          direction: AxisDirection.down,
        ),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const ScrollIntent(
          direction: AxisDirection.left,
        ),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const ScrollIntent(
          direction: AxisDirection.right,
        ),
        LogicalKeySet(LogicalKeyboardKey.pageUp): const ScrollIntent(
          direction: AxisDirection.up,
          type: ScrollIncrementType.page,
        ),
        LogicalKeySet(LogicalKeyboardKey.pageDown): const ScrollIntent(
          direction: AxisDirection.down,
          type: ScrollIncrementType.page,
        ),
      },
      actions: {
        ScrollIntent: CallbackAction<ScrollIntent>(
          onInvoke: (intent) {
            switch (intent.direction) {
              case AxisDirection.down:
              case AxisDirection.right:
                widget.onNext();
                break;
              case AxisDirection.up:
              case AxisDirection.left:
                widget.onPrevious();
                break;
            }
          },
        ),
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _overlayEnabled = !_overlayEnabled;
            });
          },
          child: Scaffold(
            body: Stack(
              children: [
                AnimatedOpacity(
                  opacity: _overlayEnabled ? 1 : 0,
                  duration: _kOverlayTransitionDuration,
                  child: _Buttons(
                    onPrevious: widget.onPrevious,
                    onNext: widget.onNext,
                  ),
                ),
                Positioned.fill(
                  child: _FunvasContainer(
                    funvas: FunvasDrawer.instance[widget.funvasKey],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _overlayEnabled ? 1 : 0,
                  duration: _kOverlayTransitionDuration,
                  child: Column(
                    children: [
                      _PageHeader(
                        onShuffle: widget.onShuffle,
                      ),
                      const Spacer(),
                      _PageFooter(
                        funvasKey: widget.funvasKey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Container that handles actually displaying the funvas animations and
/// switching between them.
class _FunvasContainer extends StatelessWidget {
  const _FunvasContainer({
    Key? key,
    required this.funvas,
  }) : super(key: key);

  /// The funvas animation to be displayed in the row.
  final Funvas funvas;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: FunvasContainer(
          funvas: funvas,
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({
    Key? key,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // We add buttons in all four directions in the stack below the funvas
        // animation. This is a smart way of supporting both mobile and
        // desktop layouts ;)
        // This way, I do not need to even check the current dimensions. If
        // the layout is vertical, the funvas animation will cover the
        // horizontally aligned buttons and vice versa :)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: InkResponse(
              onTap: onPrevious,
              radius: 42,
              child: Icon(
                Icons.arrow_left_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0xbb),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(80),
            child: InkResponse(
              onTap: onPrevious,
              radius: 42,
              child: RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.arrow_left_outlined,
                  size: 72,
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(0xbb),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: InkResponse(
              onTap: onNext,
              radius: 42,
              child: Icon(
                Icons.arrow_right_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0xbb),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(80),
            child: InkResponse(
              onTap: onNext,
              radius: 42,
              child: RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  Icons.arrow_right_outlined,
                  size: 72,
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(0xbb),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    Key? key,
    required this.onShuffle,
  }) : super(key: key);

  /// Action that will be executed when the shuffle button is tapped.
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return _Bar(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Link(
                        body: Text('@creativemaybeno'),
                        url: 'https://twitter.com/creativemaybeno',
                      ),
                      SelectableText('\'s funvas collection'),
                    ],
                  ),
                  const SelectableText(
                    'follow for new animations :)',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onShuffle,
                icon: Icon(
                  Icons.shuffle_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(
                  'shuffle animations',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({
    Key? key,
    required this.funvasKey,
  }) : super(key: key);

  /// The key to the funvas animation, i.e. the running number.
  final int funvasKey;

  @override
  Widget build(BuildContext context) {
    final funvas = FunvasDrawer.instance[funvasKey];
    return _Bar(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Link(
                body: const Text('view tweet'),
                url: funvas.tweet,
              ),
            ),
          ),
        ),
        if (funvas.creationProcess != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Link(
              body: const Text('creation process'),
              url: funvas.creationProcess!,
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Link(
                body: const Text('source code'),
                url: 'https://github.com/creativecreatorormaybenot/funvas/'
                    'blob/main/funvas_tweets/lib/src/$funvasKey.dart',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget for a horizontal bar of fixed height with content.
///
/// This can be used as a top or bottom bar.
class _Bar extends StatelessWidget {
  const _Bar({
    Key? key,
    required this.children,
  }) : super(key: key);

  /// The content of the bar.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Container(
          height: 64,
          color: Theme.of(context).colorScheme.surface.withAlpha(0xa1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
