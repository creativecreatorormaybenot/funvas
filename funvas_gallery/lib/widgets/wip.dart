import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_gallery/factories/animations.dart';

/// Displays the current [wipFunvas].
class WIPFunvasPage extends StatelessWidget {
  const WIPFunvasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): _ExitIntent(),
      },
      actions: {
        _ExitIntent: CallbackAction(
          onInvoke: (_) => Navigator.of(context).pop(),
        ),
      },
      autofocus: true,
      child: Scaffold(
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
      ),
    );
  }
}

class _ExitIntent extends Intent {}
