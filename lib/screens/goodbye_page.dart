import 'dart:async';

import 'package:flutter/material.dart';

import '../Theme/app_theme.dart';
import 'login_page.dart';

class GoodbyePage extends StatefulWidget {
  const GoodbyePage({super.key});

  @override
  State<GoodbyePage> createState() => _GoodbyePageState();
}

class _GoodbyePageState extends State<GoodbyePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), _goToLogin);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.silkBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐥', style: TextStyle(fontSize: 76)),
                const SizedBox(height: 20),
                const Text(
                  'Goodbye!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleLemon,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tracer will miss you... ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.paleLemon),
                ),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: AppTheme.paleLemon),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
