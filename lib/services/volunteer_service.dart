import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/volunteer.dart';

class VolunteerService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'profiles';

  Future<List<Volunteer>> getVolunteers({
    String? search,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    var query = _client.from(_table).select().eq('role', 'volunteer');

    if (search != null && search.isNotEmpty) {
      query = query.or(
          'full_name.ilike.%$search%,city.ilike.%$search%,phone.ilike.%$search%');
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
    return (response as List)
        .map((e) => Volunteer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Volunteer?> getVolunteerById(String id) async {
    final response =
        await _client.from(_table).select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Volunteer.fromJson(response);
  }

  Future<Volunteer> updateVolunteer(Volunteer volunteer) async {
    final data = volunteer.toJson();
    data.remove('created_at');
    final response = await _client
        .from(_table)
        .update(data)
        .eq('id', volunteer.id)
        .select()
        .single();
    return Volunteer.fromJson(response);
  }

  Future<int> getVolunteersCount() async {
    final response =
        await _client.from(_table).select('id').eq('role', 'volunteer');
    return (response as List).length;
  }

  Future<List<String>> getDistinctCities() async {
    final response =
        await _client.from(_table).select('city').eq('role', 'volunteer');
    final cities = <String>{};
    for (final row in response as List) {
      final city = (row as Map<String, dynamic>)['city'] as String?;
      if (city != null && city.isNotEmpty) cities.add(city);
    }
    return cities.toList()..sort();
  }
}
