import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.parse(AppConfig.privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Najd Volunteer Privacy Policy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: June 2026',
            style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 24),
          const _Section(
            title: 'Information we collect',
            body:
                'We collect account information (name, email, phone), volunteer profile details '
                '(skills, availability, city), messages you send through support chat, voice messages, '
                'and in-app activity such as task assignments and notifications.',
          ),
          const _Section(
            title: 'How we use information',
            body:
                'Your information is used to coordinate volunteer tasks, connect you with support staff, '
                'send in-app alerts, and operate the Najd volunteer platform. We do not sell your personal data.',
          ),
          const _Section(
            title: 'Data storage & security',
            body:
                'Data is stored securely using Supabase with row-level access controls. Only authorized '
                'coordinators can access volunteer records needed for operations.',
          ),
          const _Section(
            title: 'Your choices',
            body:
                'You can update your profile in the app, contact support for data questions, or delete '
                'your account from Settings. Deletion permanently removes your account and associated data '
                'subject to legal retention requirements.',
          ),
          const _Section(
            title: 'Contact',
            body:
                'Questions about privacy: ${AppConfig.supportEmail}',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openExternal(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View full policy online'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
