import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/volunteer.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tasksTable = 'tasks';
  static const String _assignmentsTable = 'task_assignments';

  List<TaskModel> _mapTasks(dynamic response) {
    return (response as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> _tasksQueryOrdered({
    TaskStatus? status,
    required String orderColumn,
  }) async {
    var query = _client.from(_tasksTable).select();
    if (status != null) {
      query = query.eq('status', status.name);
    }
    return query.order(orderColumn, ascending: false);
  }

  /// Orders by `date` when the column exists; falls back to `created_at` (older DBs).
  Future<List<TaskModel>> getTasks({TaskStatus? status}) async {
    try {
      final response = await _tasksQueryOrdered(status: status, orderColumn: 'date');
      return _mapTasks(response);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('PGRST204') ||
          msg.contains('42703') ||
          (msg.contains('date') &&
              (msg.contains('does not exist') || msg.contains('schema cache')))) {
        final response =
            await _tasksQueryOrdered(status: status, orderColumn: 'created_at');
        return _mapTasks(response);
      }
      rethrow;
    }
  }

  Future<TaskModel?> getTaskById(String id) async {
    final response =
        await _client.from(_tasksTable).select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return TaskModel.fromJson(response);
  }

  static bool _missingSchemaColumnError(Object e) {
    final s = e.toString();
    return s.contains('PGRST204') ||
        s.contains('42703') ||
        (s.contains('schema cache') && s.contains('column'));
  }

  Map<String, dynamic> _createPayload({
    required String title,
    required String description,
    required String location,
    required List<String> requiredSkills,
    required DateTime date,
    required TaskStatus status,
    bool includeDate = true,
    bool includeLocation = true,
    bool includeDescription = true,
    bool includeRequiredSkills = true,
  }) {
    return {
      'title': title,
      if (includeDescription) 'description': description,
      if (includeLocation) 'location': location,
      if (includeRequiredSkills) 'required_skills': requiredSkills,
      'status': status.name,
      if (includeDate) 'date': date.toIso8601String(),
    };
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String location,
    required List<String> requiredSkills,
    required DateTime date,
    TaskStatus status = TaskStatus.pending,
  }) async {
    final attempts = <Map<String, dynamic>>[
      _createPayload(
        title: title,
        description: description,
        location: location,
        requiredSkills: requiredSkills,
        date: date,
        status: status,
      ),
      _createPayload(
        title: title,
        description: description,
        location: location,
        requiredSkills: requiredSkills,
        date: date,
        status: status,
        includeDate: false,
      ),
      _createPayload(
        title: title,
        description: description,
        location: location,
        requiredSkills: requiredSkills,
        date: date,
        status: status,
        includeDate: false,
        includeLocation: false,
      ),
      _createPayload(
        title: title,
        description: description,
        location: location,
        requiredSkills: requiredSkills,
        date: date,
        status: status,
        includeDate: false,
        includeLocation: false,
        includeDescription: false,
      ),
      {
        'title': title,
        'required_skills': requiredSkills,
        'status': status.name,
      },
      {'title': title, 'status': status.name},
    ];

    Object? last;
    for (final data in attempts) {
      try {
        final response = await _client
            .from(_tasksTable)
            .insert(data)
            .select()
            .single();
        return TaskModel.fromJson(response);
      } catch (e) {
        last = e;
        if (!_missingSchemaColumnError(e)) rethrow;
      }
    }
    throw last!;
  }

  Map<String, dynamic> _updatePayload(
    TaskModel task, {
    bool includeDate = true,
    bool includeLocation = true,
    bool includeDescription = true,
    bool includeRequiredSkills = true,
  }) {
    return {
      'title': task.title,
      if (includeDescription) 'description': task.description,
      if (includeLocation) 'location': task.location,
      if (includeRequiredSkills) 'required_skills': task.requiredSkills,
      'status': task.status.name,
      if (includeDate) 'date': task.date.toIso8601String(),
    };
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final attempts = <Map<String, dynamic>>[
      _updatePayload(task),
      _updatePayload(task, includeDate: false),
      _updatePayload(task, includeDate: false, includeLocation: false),
      _updatePayload(
        task,
        includeDate: false,
        includeLocation: false,
        includeDescription: false,
      ),
      {
        'title': task.title,
        'required_skills': task.requiredSkills,
        'status': task.status.name,
      },
      {'title': task.title, 'status': task.status.name},
    ];

    Object? last;
    for (final data in attempts) {
      try {
        final response = await _client
            .from(_tasksTable)
            .update(data)
            .eq('id', task.id)
            .select()
            .single();
        return TaskModel.fromJson(response);
      } catch (e) {
        last = e;
        if (!_missingSchemaColumnError(e)) rethrow;
      }
    }
    throw last!;
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
