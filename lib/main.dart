import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const TracerApp());
}

class TracerApp extends StatelessWidget {
  const TracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracer',
      home: const HomePage(),
    );
  }
}
