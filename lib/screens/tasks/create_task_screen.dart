import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/volunteer.dart';
import '../../services/task_service.dart';
import '../../services/volunteer_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  final VolunteerService _volunteerService = VolunteerService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _date = DateTime.now();
  List<String> _requiredSkills = [];
  List<String> _selectedVolunteerIds = [];
  List<Volunteer> _volunteers = [];
  bool _loading = false;
  bool _volunteersLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadVolunteers() async {
    try {
      final list = await _volunteerService.getVolunteers();
      if (mounted) setState(() { _volunteers = list; _volunteersLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _volunteersLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final task = await _taskService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        requiredSkills: _requiredSkills,
        date: _date,
      );
      if (_selectedVolunteerIds.isNotEmpty) {
        await _taskService.assignVolunteers(task.id, _selectedVolunteerIds);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title', prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              const Text('Required Skills', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skillOptions.map((s) {
                  final selected = _requiredSkills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) _requiredSkills.add(s); else _requiredSkills.remove(s);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Assign Volunteers', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              if (_volunteersLoading)
                const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
              else if (_volunteers.isEmpty)
                const Text('No volunteers in database')
              else
                ..._volunteers.map((v) {
                  final selected = _selectedVolunteerIds.contains(v.id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) _selectedVolunteerIds.add(v.id);
                        else _selectedVolunteerIds.remove(v.id);
                      });
                    },
                    title: Text(v.fullName),
                    subtitle: Text('${v.city} • ${v.skills.join(", ")}'),
                  );
                }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
