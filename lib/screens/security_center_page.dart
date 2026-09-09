import 'package:flutter/material.dart';

class SecurityCenterPage extends StatelessWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.security, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stay Safe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Follow these security tips when '
                            'using Tracer.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Security Tips',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildSecurityCard(
              icon: Icons.lock_outline,
              title: 'Use a Strong Password',
              description:
                  'Use a password that contains uppercase '
                  'and lowercase letters, numbers, and '
                  'special characters.',
            ),

            _buildSecurityCard(
              icon: Icons.email_outlined,
              title: 'Protect Your Email',
              description:
                  'Your email may be used for password '
                  'recovery. Keep your email account secure.',
            ),

            _buildSecurityCard(
              icon: Icons.person_outline,
              title: 'Protect Personal Information',
              description:
                  'Avoid sharing sensitive personal '
                  'information in item descriptions or '
                  'public reports.',
            ),

            _buildSecurityCard(
              icon: Icons.report_problem_outlined,
              title: 'Report Carefully',
              description:
                  'Only publish information that is necessary '
                  'to identify the lost item.',
            ),

            _buildSecurityCard(
              icon: Icons.verified_user_outlined,
              title: 'Verify Before Returning',
              description:
                  'Before returning an item, verify that '
                  'the person claiming it is the rightful owner.',
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 10),
                        Text(
                          'Tracer Security',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tracer uses local SQLite storage for '
                      'application data and email verification '
                      'for password recovery.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
