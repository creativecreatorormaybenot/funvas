import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funvas_demo/widgets/page.dart';
import 'package:funvas_demo/widgets/wip.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funvas demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const _DebugWrapper(
        child: DemoPage(),
      ),
    );
  }
}

/// Wraps the WIP feature in debug mode and returns the demo page as is
/// otherwise.
class _DebugWrapper extends StatelessWidget {
  const _DebugWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyW,
        ): _DebugWIPIntent(),
      },
      actions: {
        _DebugWIPIntent: CallbackAction(
          onInvoke: (_) {
            // The transition animation for the page is a bit weird on web..
            // But hey: it is only in debug mode :D
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return const WIPFunvasPage();
              },
            ));
            return null;
          },
        ),
      },
      autofocus: true,
      child: child,
    );
  }
}

class _DebugWIPIntent extends Intent {}
