import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/volunteer.dart';

class VolunteerService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'profiles';

  /// When [coordinatorDirectory] is true (logged-in user is admin or support), loads
  /// **all** profiles via `list_profiles_for_coordinator` RPC (bypasses broken RLS).
  /// Otherwise loads only rows with `role = volunteer`.
  Future<List<Volunteer>> getVolunteers({
    String? search,
    String? city,
    List<String>? skills,
    List<String>? availability,
    String sortBy = 'created_at',
    bool ascending = false,
    bool coordinatorDirectory = false,
  }) async {
    if (coordinatorDirectory) {
      final viaRpc = await _listProfilesForCoordinatorRpc();
      if (viaRpc != null) {
        return _filterAndSortVolunteers(
          viaRpc,
          search: search,
          city: city,
          skills: skills,
          availability: availability,
          sortBy: sortBy,
          ascending: ascending,
        );
      }
    }

    var query = _client.from(_table).select();
    if (!coordinatorDirectory) {
      query = query.eq('role', 'volunteer');
    }

    if (search != null && search.isNotEmpty) {
      query = query.or(
          'full_name.ilike.%$search%,city.ilike.%$search%,phone.ilike.%$search%,email.ilike.%$search%');
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
    final list = (response as List)
        .map((e) => Volunteer.fromJson(e as Map<String, dynamic>))
        .toList();
    return _filterAndSortVolunteers(
      list,
      search: search,
      city: city,
      skills: skills,
      availability: availability,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  Future<List<Volunteer>?> _listProfilesForCoordinatorRpc() async {
    dynamic response;
    try {
      response = await _client.rpc('list_profiles_for_coordinator');
    } catch (_) {
      // Admins can use the admin-only list if the coordinator name fails (older SQL).
      try {
        response = await _client.rpc('admin_list_all_profiles');
      } catch (_) {
        return null;
      }
    }
    if (response == null) return [];
    if (response is Map) {
      return [Volunteer.fromJson(Map<String, dynamic>.from(response))];
    }
    final list = response as List;
    return list
        .map((e) => Volunteer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<Volunteer> _filterAndSortVolunteers(
    List<Volunteer> raw, {
    String? search,
    String? city,
    List<String>? skills,
    List<String>? availability,
    required String sortBy,
    required bool ascending,
  }) {
    var list = List<Volunteer>.from(raw);
    final q = search?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      list = list.where((v) {
        return v.fullName.toLowerCase().contains(q) ||
            v.city.toLowerCase().contains(q) ||
            v.phone.contains(q) ||
            v.email.toLowerCase().contains(q);
      }).toList();
    }
    if (city != null && city.isNotEmpty) {
      list = list.where((v) => v.city == city).toList();
    }
    if (skills != null && skills.isNotEmpty) {
      list = list
          .where((v) => v.skills.any((s) => skills.contains(s)))
          .toList();
    }
    if (availability != null && availability.isNotEmpty) {
      list = list
          .where((v) => v.availability.any((a) => availability.contains(a)))
          .toList();
    }
    int cmp(Volunteer a, Volunteer b) {
      switch (sortBy) {
        case 'full_name':
          return a.fullName.compareTo(b.fullName);
        case 'city':
          return a.city.compareTo(b.city);
        case 'created_at':
        default:
          return a.createdAt.compareTo(b.createdAt);
      }
    }

    list.sort((a, b) => ascending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  Future<Volunteer?> getVolunteerById(String id) async {
    final response =
        await _client.from(_table).select().eq('id', id).maybeSingle();
    if (response != null) {
      return Volunteer.fromJson(response);
    }
    final roster = await _listProfilesForCoordinatorRpc();
    if (roster == null || roster.isEmpty) return null;
    try {
      return roster.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
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

  Future<int> getVolunteersCount({bool coordinatorView = false}) async {
    if (coordinatorView) {
      final all = await _listProfilesForCoordinatorRpc();
      if (all != null) {
        return all.where((v) => v.appRole == 'volunteer').length;
      }
    }
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
