import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';

class AccountService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _profilesTable = 'profiles';

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<UserProfile?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    final response = await _client
        .from(_profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<UserProfile> getOrCreateProfile({
    String? email,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final existing = await getProfile();
    if (existing != null) return existing;

    final now = DateTime.now().toIso8601String();
    final data = {
      'id': userId,
      'full_name': '',
      'email': email ?? _client.auth.currentUser?.email ?? '',
      'phone': '',
      'city': '',
      'skills': <String>[],
      'availability': <String>[],
      'notes': null,
      'role': UserRole.volunteer.value,
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    };

    final response =
        await _client.from(_profilesTable).insert(data).select().single();
    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateRole({
    required String userId,
    required UserRole role,
  }) async {
    final response = await _client
        .from(_profilesTable)
        .update({
          'role': role.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateStatus({
    required String userId,
    required String status,
  }) async {
    final response = await _client
        .from(_profilesTable)
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromJson(response);
  }
}
