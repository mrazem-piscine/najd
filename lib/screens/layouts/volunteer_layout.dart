import 'package:flutter/material.dart';

import '../my_profile_screen.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';

class VolunteerLayout extends StatefulWidget {
  const VolunteerLayout({super.key});

  @override
  State<VolunteerLayout> createState() => _VolunteerLayoutState();
}

class _VolunteerLayoutState extends State<VolunteerLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _VolunteerHomeScreen(onNavigateToTab: (i) => setState(() => _index = i)),
      const _VolunteerTasksScreen(),
      const _VolunteerAvailabilityScreen(),
      const NotificationsScreen(),
      const _ContactSupportScreen(),
      const MyProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'My Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Availability'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.support_agent), label: 'Contact'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _VolunteerHomeScreen extends StatelessWidget {
  const _VolunteerHomeScreen({required this.onNavigateToTab});

  final void Function(int index) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => onNavigateToTab(6),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Text(
            'Welcome',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This is your volunteer space. From here you can see your tasks, update your availability, and reach the support team.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _BigActionCard(
            icon: Icons.assignment,
            title: 'My Tasks',
            subtitle: 'See tasks assigned to you',
            onTap: () => onNavigateToTab(1),
          ),
          const SizedBox(height: 12),
          _BigActionCard(
            icon: Icons.schedule,
            title: 'Availability',
            subtitle: 'Tell us when you can help',
            onTap: () => onNavigateToTab(2),
          ),
          const SizedBox(height: 12),
          _BigActionCard(
            icon: Icons.support_agent,
            title: 'Contact support',
            subtitle: 'Reach the operations team',
            onTap: () => onNavigateToTab(4),
          ),
          const SizedBox(height: 12),
          _BigActionCard(
            icon: Icons.settings,
            title: 'Settings & Sign out',
            subtitle: 'Manage account and sign out',
            onTap: () => onNavigateToTab(6),
          ),
        ],
      ),
    );
  }
}

class _VolunteerTasksScreen extends StatelessWidget {
  const _VolunteerTasksScreen();

  @override
  Widget build(BuildContext context) {
    // This is intentionally simple and read-only for volunteers.
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'My assigned tasks will appear here.\n\n'
            'This screen is read-only for volunteers. Task creation and assignment live in the Support dashboard.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

class _VolunteerAvailabilityScreen extends StatelessWidget {
  const _VolunteerAvailabilityScreen();

  @override
  Widget build(BuildContext context) {
    // Reuse the profile form for availability management.
    return const MyProfileScreen();
  }
}

class _ContactSupportScreen extends StatelessWidget {
  const _ContactSupportScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need help?',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use this page to reach the support team with questions about tasks, availability, or your profile.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support request sent')),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send to Support'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
