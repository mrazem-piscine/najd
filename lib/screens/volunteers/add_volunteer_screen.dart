import 'package:flutter/material.dart';
import '../../config/theme.dart';
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
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
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
      _cityController.text = v.city;
      _notesController.text = v.notes ?? '';
      _skills = List.from(v.skills);
      _availability = List.from(v.availability);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
          city: _cityController.text.trim(),
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
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'City', prefixIcon: Icon(Icons.location_city)),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
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
