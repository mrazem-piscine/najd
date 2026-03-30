import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/volunteer.dart';
import '../../services/volunteer_service.dart';
import '../../widgets/animations.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Volunteers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Modern search bar
          SlideInAnimation(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search by name, city, phone...',
                    hintStyle: const TextStyle(color: AppTheme.textLight),
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: AppTheme.textLight),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filter row
          SlideInAnimation(
            delay: const Duration(milliseconds: 50),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // City dropdown
                  _ModernDropdown(
                    icon: Icons.location_city,
                    label: _filterCity ?? 'All Cities',
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Cities'),
                      ),
                      ..._cities.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _filterCity = v;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  // Sort dropdown
                  _ModernSortChip(
                    currentSort: _sort,
                    onSortChanged: (v) {
                      setState(() {
                        _sort = v;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Volunteer list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _volunteers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                size: 48,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No volunteers found',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _volunteers.length,
                          itemBuilder: (context, index) {
                            final v = _volunteers[index];
                            return SlideInAnimation(
                              delay: Duration(milliseconds: index * 50),
                              child: _ModernVolunteerCard(
                                volunteer: v,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VolunteerProfileScreen(volunteerId: v.id),
                                  ),
                                ).then((_) => _load()),
                              ),
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

class _ModernDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<DropdownMenuItem<String?>> items;
  final Function(String?) onChanged;

  const _ModernDropdown({
    required this.icon,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: null,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 20, color: AppTheme.textLight),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ModernSortChip extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const _ModernSortChip({
    required this.currentSort,
    required this.onSortChanged,
  });

  String get _sortLabel {
    switch (currentSort) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.alphabetical:
        return 'A–Z';
      case SortOption.city:
        return 'City';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: currentSort,
      onSelected: onSortChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 45),
      itemBuilder: (context) => [
        _buildMenuItem(SortOption.newest, 'Newest', Icons.access_time),
        _buildMenuItem(SortOption.alphabetical, 'Alphabetical', Icons.sort_by_alpha),
        _buildMenuItem(SortOption.city, 'By City', Icons.location_city),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _sortLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(
      SortOption option, String label, IconData icon) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: currentSort == option
                  ? AppTheme.primary
                  : AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  currentSort == option ? FontWeight.w600 : FontWeight.normal,
              color: currentSort == option
                  ? AppTheme.primary
                  : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernVolunteerCard extends StatefulWidget {
  final Volunteer volunteer;
  final VoidCallback onTap;

  const _ModernVolunteerCard({
    required this.volunteer,
    required this.onTap,
  });

  @override
  State<_ModernVolunteerCard> createState() => _ModernVolunteerCardState();
}

class _ModernVolunteerCardState extends State<_ModernVolunteerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -2.0 : 0.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered ? AppTheme.cardShadowHover : AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with gradient border
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.secondary,
                        child: Text(
                          widget.volunteer.fullName.isNotEmpty
                              ? widget.volunteer.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.volunteer.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppTheme.textLight),
                            const SizedBox(width: 4),
                            Text(
                              widget.volunteer.city,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.phone,
                                size: 14, color: AppTheme.textLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.volunteer.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Skill badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...widget.volunteer.skills.take(2).map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.secondaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }),
                            ...widget.volunteer.availability.take(1).map((a) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.success.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  a,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.success,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
