import 'package:flutter/material.dart';

import '../../widgets/modern_bottom_nav.dart';
import 'coordinator_shell_tabs.dart';

/// Shell for [UserRole.support]: coordinator tabs (overview, volunteers, tasks, alerts, settings).
class SupportLayout extends StatefulWidget {
  const SupportLayout({super.key});

  @override
  State<SupportLayout> createState() => _SupportLayoutState();
}

class _SupportLayoutState extends State<SupportLayout> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = buildCoordinatorShellTabPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: kCoordinatorShellNavItems,
      ),
    );
  }
}
