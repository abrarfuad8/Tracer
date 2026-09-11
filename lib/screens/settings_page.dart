import 'package:flutter/material.dart';

import '../Theme/app_theme.dart';
import '../models/user.dart';
import '../services/session_service.dart';
import 'goodbye_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  final User user;

  const SettingsPage({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    await SessionService.clearRememberedUser();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GoodbyePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 10),

              _buildSection(
                context,
                children: [
                  RadioGroup<ThemeMode>(
                    groupValue: themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        AppTheme.setThemeMode(value);
                      }
                    },
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context: context,
                          icon: Icons.wb_sunny_outlined,
                          title: 'Light Mode',
                          subtitle: 'Use the light appearance',
                          trailing: const Radio<ThemeMode>(
                            value: ThemeMode.light,
                          ),
                          onTap: () {
                            AppTheme.setThemeMode(ThemeMode.light);
                          },
                        ),

                        Divider(
                          height: 1,
                          indent: 58,
                          endIndent: 16,
                          color: colorScheme.outlineVariant,
                        ),

                        _buildSettingTile(
                          context: context,
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Use the darker appearance',
                          trailing: const Radio<ThemeMode>(
                            value: ThemeMode.dark,
                          ),
                          onTap: () {
                            AppTheme.setThemeMode(ThemeMode.dark);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text('Account', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 10),

              _buildSection(
                context,
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(user: user),
                        ),
                      );
                    },
                  ),

                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: colorScheme.outlineVariant,
                  ),

                  _buildSettingTile(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Password',
                    subtitle: 'Change your account password',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password settings will be available soon.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 10),

              _buildSection(
                context,
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage Tracer notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notifications enabled.'
                                  : 'Notifications disabled.',
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: null,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text('About', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 10),

              _buildSection(
                context,
                children: [
                  _buildSettingTile(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'About Tracer',
                    subtitle: 'Lost and found management system',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Tracer',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            'A university final project for managing lost and found items.',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: colorScheme.onSurface),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),

            const SizedBox(width: 8),

            trailing,
          ],
        ),
      ),
    );
  }
}
