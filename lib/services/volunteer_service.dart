import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/volunteer.dart';

class VolunteerService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'volunteers';

  Future<List<Volunteer>> getVolunteers({
    String? search,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    var query = _client.from(_table).select();

    if (search != null && search.isNotEmpty) {
      query = query.or('full_name.ilike.%$search%,city.ilike.%$search%,phone.ilike.%$search%');
    }
    if (city != null && city.isNotEmpty) {
      query = query.eq('city', city);
    }
    if (skills != null && skills.isNotEmpty) {
      query = query.overlaps('skills', skills);
    }
    if (availability != null && availability.isNotEmpty) {
      query = query.overlaps('availability', availability);
    }

    final response = await query.order(sortBy, ascending: ascending);
    return (response as List).map((e) => Volunteer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Volunteer?> getVolunteerById(String id) async {
    final response = await _client.from(_table).select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Volunteer.fromJson(response as Map<String, dynamic>);
  }

  Future<Volunteer> createVolunteer({
    required String fullName,
    required String phone,
    required String city,
    required List<String> skills,
    required List<String> availability,
    String? notes,
  }) async {
    final data = {
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'skills': skills,
      'availability': availability,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final response = await _client.from(_table).insert(data).select().single();
    return Volunteer.fromJson(response as Map<String, dynamic>);
  }

  Future<Volunteer> updateVolunteer(Volunteer volunteer) async {
    final data = volunteer.toJson();
    data.remove('id');
    data.remove('created_at');
    final response = await _client
        .from(_table)
        .update(data)
        .eq('id', volunteer.id)
        .select()
        .single();
    return Volunteer.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteVolunteer(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<int> getVolunteersCount() async {
    final response = await _client.from(_table).select('id');
    return (response as List).length;
  }

  Future<List<String>> getDistinctCities() async {
    final response = await _client.from(_table).select('city');
    final cities = <String>{};
    for (final row in response as List) {
      final city = (row as Map<String, dynamic>)['city'] as String?;
      if (city != null && city.isNotEmpty) cities.add(city);
    }
    return cities.toList()..sort();
  }
}
