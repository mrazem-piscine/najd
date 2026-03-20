import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/volunteer.dart';
import '../../services/volunteer_service.dart';
import 'volunteer_profile_screen.dart';

enum SortOption { newest, alphabetical, city }

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  final VolunteerService _service = VolunteerService();
  final TextEditingController _searchController = TextEditingController();
  List<Volunteer> _volunteers = [];
  List<Volunteer> _allVolunteers = [];
  List<String> _cities = [];
  bool _loading = true;
  String? _filterCity;
  final List<String> _filterSkills = [];
  final List<String> _filterAvailability = [];
  SortOption _sort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await _service.getVolunteers();
      _cities = await _service.getDistinctCities();
      _allVolunteers = all;
      _applyFiltersAndSort(_allVolunteers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyFiltersAndSort(List<Volunteer> list) {
    var listCopy = List<Volunteer>.from(list);
    final search = _searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      listCopy = listCopy.where((v) {
        return v.fullName.toLowerCase().contains(search) ||
            v.city.toLowerCase().contains(search) ||
            v.phone.contains(search);
      }).toList();
    }
    if (_filterCity != null && _filterCity!.isNotEmpty) {
      listCopy = listCopy.where((v) => v.city == _filterCity).toList();
    }
    if (_filterSkills.isNotEmpty) {
      listCopy = listCopy
          .where((v) => v.skills.any((s) => _filterSkills.contains(s)))
          .toList();
    }
    if (_filterAvailability.isNotEmpty) {
      listCopy = listCopy
          .where(
              (v) => v.availability.any((a) => _filterAvailability.contains(a)))
          .toList();
    }
    switch (_sort) {
      case SortOption.newest:
        listCopy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.alphabetical:
        listCopy.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case SortOption.city:
        listCopy.sort((a, b) => a.city.compareTo(b.city));
        break;
    }
    _volunteers = listCopy;
  }

  void _applyFilters() {
    _applyFiltersAndSort(_allVolunteers);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, city, phone...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _filterCity,
                  hint: const Text('City'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All cities')),
                    ..._cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  ],
                  onChanged: (v) {
                    setState(() {
                      _filterCity = v;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<SortOption>(
                  initialValue: _sort,
                  onSelected: (v) {
                    setState(() {
                      _sort = v;
                      _applyFilters();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: SortOption.newest, child: Text('Newest')),
                    const PopupMenuItem(
                        value: SortOption.alphabetical,
                        child: Text('Alphabetical')),
                    const PopupMenuItem(
                        value: SortOption.city, child: Text('By City')),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.sort,
                        size: 18, color: AppTheme.primary),
                    label: Text(_sort == SortOption.newest
                        ? 'Newest'
                        : _sort == SortOption.alphabetical
                            ? 'A–Z'
                            : 'City'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _volunteers.isEmpty
                    ? Center(
                        child: Text('No volunteers found',
                            style: TextStyle(color: Colors.grey.shade600)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _volunteers.length,
                          itemBuilder: (context, index) {
                            final v = _volunteers[index];
                            return _VolunteerCard(
                              volunteer: v,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VolunteerProfileScreen(volunteerId: v.id),
                                ),
                              ).then((_) => _load()),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback onTap;

  const _VolunteerCard({required this.volunteer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                volunteer.fullName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(volunteer.city)
              ]),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: volunteer.skills
                    .take(3)
                    .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: volunteer.availability
                    .take(2)
                    .map((a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Text(volunteer.phone,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
