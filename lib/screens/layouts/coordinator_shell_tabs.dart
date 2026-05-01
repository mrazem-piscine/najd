import 'package:flutter/material.dart';

import '../../widgets/modern_bottom_nav.dart';
import '../dashboard_screen.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';
import '../tasks/task_list_screen.dart';
import '../volunteers/volunteer_list_screen.dart';

/// Bottom tabs + pages shared by [SupportLayout] and [AdminLayout]
/// (coordinator-facing: overview, volunteers, tasks, alerts, settings).
const List<ModernBottomNavItem> kCoordinatorShellNavItems = [
  ModernBottomNavItem(
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    label: 'Overview',
  ),
  ModernBottomNavItem(
    icon: Icons.people_outline,
    activeIcon: Icons.people,
    label: 'Volunteers',
  ),
  ModernBottomNavItem(
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: 'Tasks',
  ),
  ModernBottomNavItem(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Alerts',
  ),
  ModernBottomNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
  ),
];

List<Widget> buildCoordinatorShellTabPages() {
  return const [
    DashboardScreen(),
    VolunteerListScreen(),
    TaskListScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];
}
