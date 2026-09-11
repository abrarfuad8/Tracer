import 'package:flutter/material.dart';

import 'Theme/app_theme.dart';
import 'screens/startup_page.dart';

void main() {
  runApp(const TracerApp());
}

class TracerApp extends StatelessWidget {
  const TracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Tracer',

          theme: AppTheme.lightTheme,

          darkTheme: AppTheme.darkTheme,

          themeMode: themeMode,

          home: const StartupPage(),
        );
      },
    );
  }
}
