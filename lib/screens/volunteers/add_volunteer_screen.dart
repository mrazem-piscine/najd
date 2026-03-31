import 'package:flutter/material.dart';
import '../../models/volunteer.dart';
import '../../services/volunteer_service.dart';

class AddVolunteerScreen extends StatefulWidget {
  final Volunteer? editVolunteer;

  const AddVolunteerScreen({super.key, this.editVolunteer});

  @override
  State<AddVolunteerScreen> createState() => _AddVolunteerScreenState();
}

class _AddVolunteerScreenState extends State<AddVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  final VolunteerService _service = VolunteerService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _citySearchController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCity;
  List<String> _filteredCities = [];
  bool _showCityDropdown = false;
  List<String> _skills = [];
  List<String> _availability = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editVolunteer != null) {
      final v = widget.editVolunteer!;
      _nameController.text = v.fullName;
      _phoneController.text = v.phone;
      _selectedCity = v.city.isNotEmpty ? v.city : null;
      _citySearchController.text = v.city;
      _notesController.text = v.notes ?? '';
      _skills = List.from(v.skills);
      _availability = List.from(v.availability);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _citySearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCities = [];
        _showCityDropdown = false;
      });
      return;
    }
    final filtered = cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredCities = filtered;
      _showCityDropdown = filtered.isNotEmpty;
    });
  }

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
      _citySearchController.text = city;
      _showCityDropdown = false;
      _filteredCities = [];
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid city from the list')));
      return;
    }
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one skill')));
      return;
    }
    if (_availability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one availability')));
      return;
    }
    final isEdit = widget.editVolunteer != null;
    if (!isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'In the new role-based system, volunteers create their own accounts via sign up.\n'
            'Support can no longer manually create volunteer profiles here.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (isEdit) {
        final updated = widget.editVolunteer!.copyWith(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _selectedCity!,
          skills: _skills,
          availability: _availability,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await _service.updateVolunteer(updated);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Profile updated')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editVolunteer != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Volunteer' : 'Add Volunteer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // City search field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _citySearchController,
                    onChanged: _filterCities,
                    onTap: () {
                      if (_citySearchController.text.isNotEmpty) {
                        _filterCities(_citySearchController.text);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: _selectedCity != null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      hintText: 'Search for your city...',
                    ),
                    validator: (v) {
                      if (_selectedCity == null || _selectedCity!.isEmpty) {
                        return 'Please select a city from the list';
                      }
                      return null;
                    },
                  ),
                  if (_showCityDropdown && _filteredCities.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = _filteredCities[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(city),
                            onTap: () => _selectCity(city),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Skills (multi select)',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skillOptions.map((s) {
                  final selected = _skills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _skills.add(s);
                        } else {
                          _skills.remove(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Availability (multi select)',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availabilityOptions.map((a) {
                  final selected = _availability.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _availability.add(a);
                        } else {
                          _availability.remove(a);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Notes', alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Save Changes' : 'Add Volunteer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
