import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_demo/factories/animations.dart';

/// Displays the current [wipFunvas].
class WIPFunvasPage extends StatelessWidget {
  const WIPFunvasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: FunvasContainer(
              funvas: wipFunvas.funvas,
            ),
          ),
        ),
      ),
    );
  }
}
