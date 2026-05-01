import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/theme.dart';
import '../widgets/animations.dart';
import '../widgets/support_conversation_view.dart';

/// Volunteer: live chat with support (Realtime + in-app notifications for staff).
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Support chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'Sign in to contact support.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SlideInAnimation(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.headset_mic_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Messages here sync in real time. Support gets an alert '
                              'and can open this thread from Alerts.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SupportConversationView(
                    threadVolunteerId: uid,
                    isCoordinator: false,
                  ),
                ),
              ],
            ),
    );
  }
}
