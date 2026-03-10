import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'notifications';

  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _client.from(_table).update({'read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from(_table).update({'read': true}).eq('user_id', userId);
  }

  Future<int> getUnreadCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;
    final response = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('read', false);
    return (response as List).length;
  }
}
