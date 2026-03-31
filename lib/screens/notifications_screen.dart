import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getNotifications();
      if (mounted) setState(() => _notifications = list);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No notifications', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: n.read ? null : AppTheme.secondary.withOpacity(0.1),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n.type == 'emergency' ? Colors.red : AppTheme.primary,
                            child: Icon(
                              n.type == 'emergency' ? Icons.warning : Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(n.body),
                              const SizedBox(height: 4),
                              Text(DateFormat.yMMMd().add_jm().format(n.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            if (!n.read) await _service.markAsRead(n.id);
                            _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
