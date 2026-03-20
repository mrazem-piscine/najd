import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_profile.dart';
import '../../models/user_role.dart';
import '../../services/account_service.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _UserManagementScreen(),
      const _RoleManagementScreen(),
      const _SupportTeamManagementScreen(),
      const _SystemSettingsScreen(),
      const _ReportsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Roles'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'System'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}

class _UserManagementScreen extends StatefulWidget {
  const _UserManagementScreen();

  @override
  State<_UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<_UserManagementScreen> {
  final AccountService _accountService = AccountService();
  List<UserProfile> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _fetchAllProfiles();
      if (mounted) setState(() => _users = data);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<List<UserProfile>> _fetchAllProfiles() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('profiles').select().order('created_at');
    return (response as List)
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _changeRole(UserProfile user, UserRole role) async {
    try {
      final updated = await _accountService.updateRole(userId: user.id, role: role);
      if (!mounted) return;
      setState(() {
        _users = _users.map((u) => u.id == updated.id ? updated : u).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated role for ${user.fullName}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update role')),
      );
    }
  }

  Future<void> _setStatus(UserProfile user, String status) async {
    try {
      final updated = await _accountService.updateStatus(userId: user.id, status: status);
      if (!mounted) return;
      setState(() {
        _users = _users.map((u) => u.id == updated.id ? updated : u).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated status for ${user.fullName}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final u = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(u.fullName.isNotEmpty ? u.fullName : u.email),
                      subtitle: Text('${u.email}\n${u.city.isNotEmpty ? u.city : 'No city'}'),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DropdownButton<UserRole>(
                            value: u.role,
                            underline: const SizedBox.shrink(),
                            onChanged: (value) {
                              if (value == null) return;
                              _changeRole(u, value);
                            },
                            items: const [
                              DropdownMenuItem(
                                value: UserRole.volunteer,
                                child: Text('Volunteer'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.support,
                                child: Text('Support'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.admin,
                                child: Text('Admin'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: u.status,
                            underline: const SizedBox.shrink(),
                            onChanged: (value) {
                              if (value == null) return;
                              _setStatus(u, value);
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                              DropdownMenuItem(
                                value: 'deactivated',
                                child: Text('Deactivated'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RoleManagementScreen extends StatelessWidget {
  const _RoleManagementScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role Management')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Admins can promote volunteers to support, or demote support back to volunteer from the User Management tab.\n\n'
            'This section can later be extended with more granular permissions if needed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SupportTeamManagementScreen extends StatelessWidget {
  const _SupportTeamManagementScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Team Management')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Support team members should each have their own account.\n\n'
            'Use User Management to assign the Support role to the right people.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SystemSettingsScreen extends StatelessWidget {
  const _SystemSettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'System-level configuration for the Najd platform can live here.\n\n'
            'For now this is a placeholder screen to keep the admin layout structured.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ReportsScreen extends StatelessWidget {
  const _ReportsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'High-level reports and system activity will be shown here.\n\n'
            'Admins can use this area to understand volunteer activity and support operations.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

