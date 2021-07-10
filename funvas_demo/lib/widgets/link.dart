import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart' as ull;
import 'package:url_launcher/link.dart' show LinkTarget;

/// Widget for standard HTML-styled links that behave like anchor (`<a>`
/// elements).
///
/// The main difference is that this does not detect whether the link has been
/// visited before.
class Link extends StatelessWidget {
  /// Creates a [Link] widget.
  const Link({
    Key? key,
    required this.url,
    required this.body,
    this.targetBlank = true,
  }) : super(key: key);

  /// The URL to be opened when clicking the link.
  ///
  /// This is also previewed by the browser on hover.
  final String url;

  /// The body of the link.
  ///
  /// This is usually a [Text] widget. By default, HTML-like styling is applied
  /// using [DefaultTextStyle]. It is recommended to not override the style.
  final Widget body;

  /// Whether the `<a>` target should be blank.
  ///
  /// Defaults to `true`.
  ///
  /// Leaving this `null` will delegate to [LinkTarget.defaultTarget], also
  /// for mobile support.
  final bool? targetBlank;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ull.Link(
        uri: Uri.tryParse(url),
        target: targetBlank == null
            ? LinkTarget.defaultTarget
            : targetBlank!
            ? LinkTarget.blank
            : LinkTarget.self,
        builder: (context, followLink) {
          return GestureDetector(
            onTap: followLink,
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                decoration: TextDecoration.underline,
                // The default link color according to the HTML living standard.
                // See https://html.spec.whatwg.org/multipage/rendering.html#phrasing-content-3,
                // which defines :link { color: #0000EE; }.
                color: Color(0xff0000ee),
              ),
              child: body,
            ),
          );
        },
      ),
    );
  }
}
