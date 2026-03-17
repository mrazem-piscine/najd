import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/volunteer.dart';
import '../services/user_profile_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  Volunteer? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final v = await _profileService.getProfileAsVolunteer();
      if (mounted) setState(() => _profile = v);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null ||
        (_profile!.fullName.isEmpty && _profile!.phone.isEmpty)) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('You have not created a profile yet.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _MyProfileFormScreen()),
                ).then((_) => _load()),
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      );
    }
    final v = _profile!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _MyProfileFormScreen()),
            ).then((_) => _load()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.secondary,
                      child: Text(
                        v.fullName.isNotEmpty
                            ? v.fullName[0].toUpperCase()
                            : '?',
                        style:
                            const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(v.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(v.city, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(v.phone)),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('City'),
                subtitle: Text(v.city)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Skills'),
              subtitle: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: v.skills.map((s) => Chip(label: Text(s))).toList()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Availability'),
              subtitle: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      v.availability.map((a) => Chip(label: Text(a))).toList()),
            ),
            if (v.notes != null && v.notes!.isNotEmpty) ...[
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Notes'),
                  subtitle: Text(v.notes!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyProfileFormScreen extends StatefulWidget {
  const _MyProfileFormScreen();

  @override
  State<_MyProfileFormScreen> createState() => _MyProfileFormScreenState();
}

class _MyProfileFormScreenState extends State<_MyProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserProfileService _profileService = UserProfileService();
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
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final v = await _profileService.getProfileAsVolunteer();
    if (v != null && mounted) {
      _nameController.text = v.fullName;
      _phoneController.text = v.phone;
      _cityController.text = v.city;
      _notesController.text = v.notes ?? '';
      _skills = List.from(v.skills);
      _availability = List.from(v.availability);
      setState(() {});
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
    if (_skills.isEmpty || _availability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select at least one skill and availability')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _profileService.upsertProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        skills: _skills,
        availability: _availability,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
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
                    labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
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
              const Text('Skills',
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
              const Text('Availability',
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
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
