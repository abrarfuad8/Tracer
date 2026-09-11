import 'package:flutter/material.dart';

import '../Theme/app_theme.dart';
import '../models/user.dart';
import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  final User user;
  final bool rememberMe;

  const WelcomePage({super.key, required this.user, this.rememberMe = false});

  void _continue(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(user: user)),
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
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppTheme.paleLemon,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Image.asset(
                    'assets/images/hi.gif',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome, ${user.name}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.paleLemon,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You are all set.\nLet’s find what matters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.paleLemon,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _continue(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.paleLemon,
                      foregroundColor: AppTheme.silkBlueStrong,
                    ),
                    child: const Text('Continue'),
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
