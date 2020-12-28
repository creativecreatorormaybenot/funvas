import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  @override
  Widget build(BuildContext context) {
    final funvas = FunvasDrawer.instance[_funvasIndex];

    return Scaffold(
      body: Column(
        children: [
          _PageHeader(
            onShuffle: () {
              FunvasDrawer.instance.shuffle();

              setState(() {
                _funvasIndex = 0;
              });
            },
          ),
          Expanded(
            child: _FunvasContainer(
              funvas: funvas,
              onNext: () {
                setState(() {
                  _funvasIndex++;
                });
              },
              onPrevious: () {
                setState(() {
                  _funvasIndex--;
                });
              },
            ),
          ),
          _PageFooter(
            tweetUrl: funvas.tweet,
          ),
        ],
      ),
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
    return Container(
      height: 64,
      color: const Color(0x33ffffff),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Link(
                      text: '@creativemaybeno',
                      url: 'https://twitter.com/creativemaybeno',
                    ),
                    SelectableText('\'s funvas collection'),
                  ],
                ),
                SelectableText(
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
                label: Text(
                  'shuffle animations',
                  style: TextStyle(color: const Color(0xffffffff)),
                ),
              ),
            ),
          ),
        ],
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
  }) : super(key: key);

  /// The funvas animation to be displayed in the row.
  final Funvas funvas;

  /// Action that will be executed when the next button is tapped.
  final VoidCallback onNext;

  /// Action that will be executed when the previous button is tapped.
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // We add buttons in all four directions in the stack below the funvas
        // animation. This is a smart way of supporting both mobile and desktop
        // layouts ;)
        // This way, I do not need to even check the current dimensions. If the
        // layout is vertical, the funvas animation will cover the horizontally
        // aligned buttons and vice versa :)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: InkResponse(
              onTap: onPrevious,
              radius: 42,
              child: RotatedBox(
                quarterTurns: 1,
                child: const Icon(
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
            padding: const EdgeInsets.all(32),
            child: InkResponse(
              onTap: onPrevious,
              radius: 42,
              child: RotatedBox(
                quarterTurns: -2,
                child: const Icon(
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
            padding: const EdgeInsets.all(32),
            child: InkResponse(
              onTap: onNext,
              radius: 42,
              child: RotatedBox(
                quarterTurns: -1,
                child: const Icon(
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
            padding: const EdgeInsets.all(32),
            child: InkResponse(
              onTap: onNext,
              radius: 42,
              child: RotatedBox(
                quarterTurns: 0,
                child: const Icon(
                  Icons.arrow_circle_down_outlined,
                  size: 72,
                  color: Color(0xbbffffff),
                ),
              ),
            ),
          ),
        ),
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

class _PageFooter extends StatelessWidget {
  const _PageFooter({
    Key? key,
    required this.tweetUrl,
  }) : super(key: key);

  /// The URL for the tweet for the currently displayed funvas animation.
  final String tweetUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0x33ffffff),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Link(
            text: 'view tweet (w/ source code)',
            url: tweetUrl,
          ),
        ],
      ),
    );
  }
}
