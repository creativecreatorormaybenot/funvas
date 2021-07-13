import 'package:flutter/material.dart';
import 'package:funvas_gallery/widgets/app.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  // We need to use the hash URL strategy because GitHub pages does not support
  // single page apps.
  setHashUrlStrategy();
  runApp(const DemoApp());
}
