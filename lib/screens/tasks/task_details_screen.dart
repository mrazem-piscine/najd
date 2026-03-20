import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../models/volunteer.dart';
import '../../services/task_service.dart';
import '../volunteers/volunteer_profile_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TaskService _service = TaskService();
  TaskModel? _task;
  List<Volunteer> _assigned = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final task = await _service.getTaskById(widget.taskId);
      List<Volunteer> assigned = [];
      if (task != null) {
        assigned = await _service.getAssignedVolunteers(task.id);
      }
      if (mounted) {
        setState(() {
          _task = task;
          _assigned = assigned;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateStatus(TaskStatus status) async {
    if (_task == null) return;
    try {
      await _service.updateTaskStatus(_task!.id, status);
      if (mounted) setState(() => _task = _task!.copyWith(status: status));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: const Center(child: Text('Task not found')),
      );
    }
    final task = _task!;
    final statusColor = task.status == TaskStatus.completed
        ? Colors.teal
        : task.status == TaskStatus.active
            ? Colors.orange
            : Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (task.status != TaskStatus.completed)
            PopupMenuButton<TaskStatus>(
              onSelected: _updateStatus,
              itemBuilder: (context) => [
                if (task.status != TaskStatus.active)
                  const PopupMenuItem(
                      value: TaskStatus.active, child: Text('Mark Active')),
                const PopupMenuItem(
                    value: TaskStatus.completed, child: Text('Mark Completed')),
              ],
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(task.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold))),
                        Chip(
                            label: Text(task.status.displayName),
                            backgroundColor: statusColor.withOpacity(0.2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(task.description),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on),
                      title: const Text('Location'),
                      subtitle: Text(task.location),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle:
                          Text(DateFormat.yMMMd().add_jm().format(task.date)),
                    ),
                    if (task.requiredSkills.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Required Skills'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: task.requiredSkills
                            .map((s) => Chip(label: Text(s)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Assigned Volunteers (${_assigned.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_assigned.isEmpty)
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No volunteers assigned')))
            else
              ..._assigned.map((v) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                          child: Text(v.fullName.isNotEmpty
                              ? v.fullName[0].toUpperCase()
                              : '?')),
                      title: Text(v.fullName),
                      subtitle: Text('${v.phone} • ${v.city}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                VolunteerProfileScreen(volunteerId: v.id)),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
