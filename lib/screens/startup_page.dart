import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../services/user_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    _checkRememberedSession();
  }

  Future<void> _checkRememberedSession() async {
    final userId = await SessionService.getRememberedUserId();

    if (!mounted) return;

    if (userId == null) {
      _openLogin();
      return;
    }

    final user = await _userService.getUserById(userId);

    if (!mounted) return;

    if (user == null) {
      await SessionService.clearRememberedUser();

      if (!mounted) return;

      _openLogin();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage(user: user)),
    );
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.track_changes_rounded,
                size: 38,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Tracer', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 18),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
