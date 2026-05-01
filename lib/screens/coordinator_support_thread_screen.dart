import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/support_conversation_view.dart';

/// Admin/support: full chat with one volunteer (thread = their user id).
class CoordinatorSupportThreadScreen extends StatelessWidget {
  const CoordinatorSupportThreadScreen({
    super.key,
    required this.volunteerUserId,
    required this.volunteerDisplayName,
    this.volunteerEmail,
  });

  final String volunteerUserId;
  final String volunteerDisplayName;
  final String? volunteerEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              volunteerDisplayName,
              style: const TextStyle(fontSize: 17),
            ),
            if (volunteerEmail != null && volunteerEmail!.isNotEmpty)
              Text(
                volunteerEmail!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SupportConversationView(
        threadVolunteerId: volunteerUserId,
        isCoordinator: true,
      ),
    );
  }
}
