import 'package:flutter/material.dart';

class AboutTracerPage extends StatelessWidget {
  const AboutTracerPage({super.key});

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Tracer',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'A university final project for managing lost and found items.',
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Tracer'),
          content: const Text(
            'Tracer is a Lost & Found Management System designed to help '
            'users report, manage, and track lost and found items in an '
            'organized and simple way.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHowItWorks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How Tracer Works'),
          content: const Text(
            'Users can create an account, report lost items, provide '
            'relevant details, and manage their reports. Tracer helps '
            'organize lost and found information to make the process '
            'easier and more efficient.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const Text(
            'Tracer respects user privacy. Account information and '
            'reported item details are used only to provide the services '
            'and functionality of the application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About Tracer')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          // App identity
          Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Image.asset(
                  'assets/images/hi.webp',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Tracer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Lost & Found Management System',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Information
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _buildTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About Tracer',
                  subtitle: 'Learn more about the application',
                  onTap: () => _showAbout(context),
                ),

                _divider(colorScheme),

                _buildTile(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  title: 'How Tracer Works',
                  subtitle: 'Learn how the system works',
                  onTap: () => _showHowItWorks(context),
                ),

                _divider(colorScheme),

                _buildTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Learn how your information is handled',
                  onTap: () => _showPrivacy(context),
                ),

                _divider(colorScheme),

                _buildTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  subtitle: 'Open-source licenses used by Tracer',
                  onTap: () => _showLicenses(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          Center(
            child: Column(
              children: [
                Text(
                  'Made with Flutter',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 5),
                Text(
                  'Tracer • 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: colorScheme.onSurface),
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

            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: colorScheme.outlineVariant,
    );
  }
}
