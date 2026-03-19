import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/volunteer.dart';
import '../../services/volunteer_service.dart';
import 'add_volunteer_screen.dart';

class VolunteerProfileScreen extends StatefulWidget {
  final String volunteerId;

  const VolunteerProfileScreen({super.key, required this.volunteerId});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final VolunteerService _service = VolunteerService();
  Volunteer? _volunteer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final v = await _service.getVolunteerById(widget.volunteerId);
      if (mounted) setState(() => _volunteer = v);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_volunteer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Volunteer not found')),
      );
    }
    final v = _volunteer!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVolunteerScreen(editVolunteer: v),
              ),
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
                        v.fullName.isNotEmpty ? v.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(v.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
              subtitle: Text(v.phone),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                onPressed: () => _call(v.phone),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('City'),
              subtitle: Text(v.city),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Skills'),
              subtitle: Wrap(spacing: 6, runSpacing: 6, children: v.skills.map((s) => Chip(label: Text(s))).toList()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Availability'),
              subtitle: Wrap(spacing: 6, runSpacing: 6, children: v.availability.map((a) => Chip(label: Text(a))).toList()),
            ),
            if (v.notes != null && v.notes!.isNotEmpty) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Notes'),
                subtitle: Text(v.notes!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
