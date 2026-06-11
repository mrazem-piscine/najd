import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.parse(AppConfig.termsOfServiceUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open terms link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Najd Volunteer Terms of Service',
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
            title: 'Acceptance',
            body:
                'By using Najd Volunteer you agree to these terms and to use the app responsibly '
                'as part of volunteer coordination efforts.',
          ),
          const _Section(
            title: 'Accounts',
            body:
                'You are responsible for keeping your login credentials secure. Coordinators may '
                'change your role or deactivate accounts that violate platform rules.',
          ),
          const _Section(
            title: 'Acceptable use',
            body:
                'Do not harass others, share unlawful content, or misuse volunteer data. '
                'Report abuse through Support or by emailing ${AppConfig.supportEmail}.',
          ),
          const _Section(
            title: 'Service availability',
            body:
                'We strive for reliable service but do not guarantee uninterrupted access. '
                'Features may change as the platform evolves.',
          ),
          const _Section(
            title: 'Termination',
            body:
                'You may delete your account at any time from Settings. We may suspend accounts '
                'that breach these terms.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openExternal(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View full terms online'),
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
