import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/app_notification.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../services/support_message_service.dart';
import '../widgets/animations.dart';
import 'coordinator_support_thread_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final SupportMessageService _supportService = SupportMessageService();
  List<AppNotification> _notifications = [];
  List<SupportThreadRow> _volunteerMessages = [];
  bool _loading = true;
  bool _loadingMessages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final role = context.read<AuthProvider>().role;
    final coordinator =
        role == UserRole.admin || role == UserRole.support;

    if (coordinator) {
      setState(() => _loadingMessages = true);
      try {
        final msgs = await _supportService.listForCoordinator();
        if (mounted) setState(() => _volunteerMessages = msgs);
      } catch (_) {
        if (mounted) setState(() => _volunteerMessages = []);
      }
      if (mounted) setState(() => _loadingMessages = false);
    }

    try {
      final list = await _notificationService.getNotifications();
      if (mounted) setState(() => _notifications = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllAsRead();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final coordinator =
        role == UserRole.admin || role == UserRole.support;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (coordinator) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: SlideInAnimation(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.pinkGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.forum_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Volunteer messages',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Full thread from Contact support',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_loadingMessages)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      )
                    else if (_volunteerMessages.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: const Text(
                              'No threads yet. Run supabase/support_messages_and_tasks.sql '
                              'in the Supabase SQL editor, then volunteers can message from Support.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final m = _volunteerMessages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SlideInAnimation(
                                  delay: Duration(
                                    milliseconds: 40 * index.clamp(0, 12),
                                  ),
                                  child: _VolunteerMessageCard(
                                  row: m,
                                  onOpenChat: m.fromUserId.isEmpty
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  CoordinatorSupportThreadScreen(
                                                volunteerUserId: m.fromUserId,
                                                volunteerDisplayName:
                                                    m.displaySender,
                                                volunteerEmail: m.senderEmail
                                                        .isEmpty
                                                    ? null
                                                    : m.senderEmail,
                                              ),
                                            ),
                                          );
                                        },
                                ),
                                ),
                              );
                            },
                            childCount: _volunteerMessages.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          'Your notifications',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ),
                    ),
                  ],
                  if (_notifications.isEmpty &&
                      (!coordinator || _volunteerMessages.isEmpty))
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 72,
                              color: AppTheme.textLight.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nothing here yet',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_notifications.isEmpty && coordinator)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Text(
                          'No other notifications yet.',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        coordinator ? 0 : 8,
                        20,
                        32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final n = _notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _NotificationTile(
                                notification: n,
                                onTap: () async {
                                  if (!n.read) {
                                    await _notificationService.markAsRead(n.id);
                                    _load();
                                  }
                                },
                              ),
                            );
                          },
                          childCount: _notifications.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _VolunteerMessageCard extends StatelessWidget {
  const _VolunteerMessageCard({
    required this.row,
    this.onOpenChat,
  });

  final SupportThreadRow row;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.secondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.secondary.withOpacity(0.2),
                child: Text(
                  row.displaySender.isNotEmpty
                      ? row.displaySender[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.displaySender,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (row.senderEmail.isNotEmpty &&
                        row.senderEmail != row.displaySender)
                      Text(
                        row.senderEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                DateFormat.MMMd().add_jm().format(row.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            row.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.textPrimary,
            ),
          ),
          if (onOpenChat != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenChat,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: const Text('Open chat'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSupport = notification.type == 'support_message';
    final gradient = isSupport ? AppTheme.pinkGradient : AppTheme.primaryGradient;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.read
                  ? const Color(0xFFE2E8F0)
                  : AppTheme.primary.withOpacity(0.25),
              width: notification.read ? 1 : 1.5,
            ),
            boxShadow: notification.read ? AppTheme.cardShadow : AppTheme.cardShadowHover,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: notification.type == 'emergency'
                      ? AppTheme.redGradient
                      : gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSupport
                      ? Icons.mark_unread_chat_alt_rounded
                      : notification.type == 'emergency'
                          ? Icons.warning_amber_rounded
                          : Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            notification.read ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
