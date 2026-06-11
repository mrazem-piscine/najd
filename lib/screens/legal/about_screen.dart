import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../config/theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {'subject': 'Najd Volunteer App Support'},
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email: ${AppConfig.supportEmail}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Najd Volunteer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Center(
            child: Text(
              'Version ${AppConfig.appVersion}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Najd Volunteer connects volunteers with coordinators for task assignment, '
            'scheduling, and support communication.',
            style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Support'),
            subtitle: Text(AppConfig.supportEmail),
            onTap: () => _emailSupport(context),
          ),
          if (AppConfig.supportPhone.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone'),
              subtitle: Text(AppConfig.supportPhone),
              onTap: () => launchUrl(Uri.parse('tel:${AppConfig.supportPhone}')),
            ),
        ],
      ),
    );
  }
}
