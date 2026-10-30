import 'package:flutter/material.dart';

import 'gallery_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'vector_pulse_icon',
    theme: ThemeData(colorSchemeSeed: const Color(0xFF6C5CE7)),
    home: const GalleryPage(),
  );
}
