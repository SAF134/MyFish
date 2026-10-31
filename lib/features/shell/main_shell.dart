import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../schedule/schedule_page.dart';
import '../settings/settings_page.dart';

/// Shell navigasi utama: 4 tab dengan bottom nav pill.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _items = [
    AppNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    AppNavItem(
      label: 'Jadwal',
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
    ),
    AppNavItem(
      label: 'Riwayat',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
    ),
    AppNavItem(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
  ];

  late final List<Widget> _pages = [
    HomePage(onViewAllSchedules: () => _select(1)),
    const SchedulePage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  late int _index = widget.initialIndex;

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // Tombol kembali di tab selain Beranda → kembali ke Beranda dulu.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: AppBottomNav(
          items: _items,
          currentIndex: _index,
          onTap: _select,
        ),
      ),
    );
  }
}
