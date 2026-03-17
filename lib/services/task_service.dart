import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/volunteer.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tasksTable = 'tasks';
  static const String _assignmentsTable = 'task_assignments';

  Future<List<TaskModel>> getTasks({TaskStatus? status}) async {
    var query = _client.from(_tasksTable).select();
    if (status != null) {
      query = query.eq('status', status.name);
    }
    final response = await query.order('date', ascending: false);
    return (response as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    final response =
        await _client.from(_tasksTable).select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return TaskModel.fromJson(response);
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String location,
    required List<String> requiredSkills,
    required DateTime date,
    TaskStatus status = TaskStatus.pending,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'location': location,
      'required_skills': requiredSkills,
      'date': date.toIso8601String(),
      'status': status.name,
    };
    final response =
        await _client.from(_tasksTable).insert(data).select().single();
    return TaskModel.fromJson(response);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final data = {
      'title': task.title,
      'description': task.description,
      'location': task.location,
      'required_skills': task.requiredSkills,
      'date': task.date.toIso8601String(),
      'status': task.status.name,
    };
    final response = await _client
        .from(_tasksTable)
        .update(data)
        .eq('id', task.id)
        .select()
        .single();
    return TaskModel.fromJson(response);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _client
        .from(_tasksTable)
        .update({'status': status.name}).eq('id', taskId);
  }

  Future<void> deleteTask(String id) async {
    await _client.from(_tasksTable).delete().eq('id', id);
  }

  Future<List<Volunteer>> getAssignedVolunteers(String taskId) async {
    final assignments = await _client
        .from(_assignmentsTable)
        .select('volunteer_id')
        .eq('task_id', taskId);
    if (assignments.isEmpty) return [];
    final ids = (assignments as List)
        .map((e) => (e as Map)['volunteer_id'] as String)
        .toList();
    final volunteers =
        await _client.from('profiles').select().inFilter('id', ids);
    return (volunteers as List)
        .map((e) => Volunteer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignVolunteers(
      String taskId, List<String> volunteerIds) async {
    await _client.from(_assignmentsTable).delete().eq('task_id', taskId);
    if (volunteerIds.isEmpty) return;
    final rows = volunteerIds
        .map((vId) => {'task_id': taskId, 'volunteer_id': vId})
        .toList();
    await _client.from(_assignmentsTable).insert(rows);
  }

  Future<int> getActiveTasksCount() async {
    final response = await _client
        .from(_tasksTable)
        .select('id')
        .inFilter('status', ['pending', 'active']);
    return (response as List).length;
  }

  Future<int> getCompletedTasksCount() async {
    final response =
        await _client.from(_tasksTable).select('id').eq('status', 'completed');
    return (response as List).length;
  }
}
