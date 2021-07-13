import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funvas_gallery/widgets/wip.dart';

/// Wraps the WIP feature in debug mode and returns the gallery page as is
/// otherwise.
class DebugWrapper extends StatelessWidget {
  const DebugWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Shortcuts(
      // We do not need to include a focus node for these shortcuts because
      // we know that the gallery page will auto focus and we only need *some*
      // child node to have focus.
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyW,
        ): _DebugWIPIntent(),
        // Also allow alt + control + w on Windows as otherwise the tab will
        // be closed on web :)
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.alt,
          LogicalKeyboardKey.keyW,
        ): _DebugWIPIntent(),
      },
      child: Actions(
        actions: {
          _DebugWIPIntent: CallbackAction(
            onInvoke: (_) {
              Overlay.of(context)!.insert(OverlayEntry(
                opaque: true,
                builder: (context) => const WIPFunvasPage(),
              ));
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _DebugWIPIntent extends Intent {}
