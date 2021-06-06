import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/drawer.dart';
import 'package:funvas_demo/widgets/link.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  var _funvasIndex = 0;
  var _overlayEnabled = true;

  void _shuffle() {
    FunvasDrawer.instance.shuffle();

    setState(() {
      _funvasIndex = 0;
    });
  }

  void _goNext() {
    setState(() {
      _funvasIndex++;
    });
  }

  void _goPrevious() {
    setState(() {
      _funvasIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final funvas = FunvasDrawer.instance[_funvasIndex];

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
              case AxisDirection.up:
              case AxisDirection.right:
                _goNext();
                break;
              case AxisDirection.down:
              case AxisDirection.left:
                _goPrevious();
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
                SizedBox.expand(
                  child: _FunvasContainer(
                    funvas: funvas,
                    onNext: _goNext,
                    onPrevious: _goPrevious,
                    overlayEnabled: _overlayEnabled,
                  ),
                ),
                if (_overlayEnabled) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _PageFooter(
                      tweetUrl: funvas.tweet,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: _PageHeader(
                      onShuffle: _shuffle,
                    ),
                  ),
                ],
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
    required this.onNext,
    required this.onPrevious,
    required this.overlayEnabled,
  }) : super(key: key);

  /// The funvas animation to be displayed in the row.
  final Funvas funvas;

  /// Action that will be executed when the next button is tapped.
  final VoidCallback onNext;

  /// Action that will be executed when the previous button is tapped.
  final VoidCallback onPrevious;

  /// Whether the button actions should be shown.
  final bool overlayEnabled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (overlayEnabled) ...[
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
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 72,
                    color: Color(0xbbffffff),
                  ),
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
                child: const RotatedBox(
                  quarterTurns: -2,
                  child: Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 72,
                    color: Color(0xbbffffff),
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
                child: const RotatedBox(
                  quarterTurns: -1,
                  child: Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 72,
                    color: Color(0xbbffffff),
                  ),
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
                child: const RotatedBox(
                  quarterTurns: 0,
                  child: Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 72,
                    color: Color(0xbbffffff),
                  ),
                ),
              ),
            ),
          ),
        ],
        SizedBox.expand(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: FunvasContainer(
                funvas: funvas,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Link(
                    text: '@creativemaybeno',
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
        Expanded(
          child: Center(
            child: OutlinedButton.icon(
              onPressed: onShuffle,
              icon: const Icon(
                Icons.shuffle_outlined,
                color: Color(0xffffffff),
              ),
              label: const Text(
                'shuffle animations',
                style: TextStyle(color: Color(0xffffffff)),
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
    required this.tweetUrl,
  }) : super(key: key);

  /// The URL for the tweet for the currently displayed funvas animation.
  final String tweetUrl;

  @override
  Widget build(BuildContext context) {
    return _Bar(
      children: [
        Link(
          text: 'view tweet (w/ source code)',
          url: tweetUrl,
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
          color: const Color(0x66666666),
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
