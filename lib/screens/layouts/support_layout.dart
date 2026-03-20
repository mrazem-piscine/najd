import 'package:flutter/material.dart';

import '../dashboard_screen.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';
import '../tasks/task_list_screen.dart';
import '../volunteers/volunteer_list_screen.dart';

class SupportLayout extends StatefulWidget {
  const SupportLayout({super.key});

  @override
  State<SupportLayout> createState() => _SupportLayoutState();
}

class _SupportLayoutState extends State<SupportLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardScreen(),
      const VolunteerListScreen(),
      const TaskListScreen(),
      const NotificationsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Volunteers'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

