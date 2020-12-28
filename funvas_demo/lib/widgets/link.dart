import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:url_launcher/url_launcher.dart';

/// Widget that displays a clickable link for a given [url].
class Link extends StatelessWidget {
  const Link({
    Key? key,
    required this.text,
    required this.url,
  }) : super(key: key);

  /// The text that should be clickable.
  final String text;

  /// The URL that should be opened on click.
  ///
  /// This is also displayed in a tooltip.
  final String url;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: url,
      child: MouseRegion(
        cursor: MaterialStateMouseCursor.clickable,
        child: GestureDetector(
          onTap: () {
            launch(url);
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: const Color(0xffddddff),
            ),
          ),
        ),
      ),
    );
  }
}
