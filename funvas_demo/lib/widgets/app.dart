import 'package:flutter/material.dart';
import 'package:funvas_demo/widgets/page.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funvas demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const DemoPage(),
    );
  }
}
