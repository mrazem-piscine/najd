import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _understood = false;
  bool _deleting = false;
  String? _error;

  static const _confirmPhrase = 'DELETE';

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _openWebDeletion() async {
    final uri = Uri.parse(AppConfig.accountDeletionWebUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visit: ${AppConfig.accountDeletionWebUrl}')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (!_understood || _confirmController.text.trim() != _confirmPhrase) {
      setState(() => _error = 'Type $_confirmPhrase to confirm.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account permanently?'),
        content: const Text(
          'This cannot be undone. Your profile, messages, notifications, '
          'and task assignments will be removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deleting = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has been deleted.')),
      );
    } else {
      setState(() {
        _deleting = false;
        _error = auth.error ?? 'Account deletion failed. Try the web form or contact support.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _understood &&
        _confirmController.text.trim() == _confirmPhrase &&
        !_deleting;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.error),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deleting your account is permanent. You will lose access to tasks, '
                    'support history, and notifications.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What happens when you delete',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Your login and profile are removed\n'
            '• Support messages and voice notes are deleted\n'
            '• Task assignments linked to you are removed\n'
            '• This action cannot be reversed',
            style: TextStyle(height: 1.6, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _understood,
            onChanged: _deleting
                ? null
                : (v) => setState(() => _understood = v ?? false),
            title: const Text('I understand this is permanent'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            enabled: !_deleting,
            decoration: InputDecoration(
              labelText: 'Type $_confirmPhrase to confirm',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: canSubmit ? _deleteAccount : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _deleting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete my account'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _deleting ? null : _openWebDeletion,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Request deletion via web form'),
          ),
          const SizedBox(height: 12),
          Text(
            'If in-app deletion fails, use the web form or email ${AppConfig.supportEmail}.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}
