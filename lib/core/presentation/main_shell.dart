import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../../features/finance/presentation/finance_screen.dart';
import 'visi_logo.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const ClientsScreen(),
    const FinanceScreen(),
    const Scaffold(
      backgroundColor: Color(0xFF060E1A),
      body: Center(
        child: Text('Ustawienia', style: TextStyle(color: Colors.white)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: VisiAIButton(
        onTap: () => VisiAIPanel.show(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildGlassNavBar(),
    );
  }

  Widget _buildGlassNavBar() {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.calendar_today_rounded, 'Kalendarz'),
                _navItem(1, Icons.people_alt_rounded, 'Klienci'),
                _navItem(2, Icons.payments_rounded, 'Finanse'),
                _navItem(3, Icons.settings_rounded, 'Opcje'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2E5B8A).withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4A7FB5)
                  : Colors.white.withValues(alpha: 0.4),
              size: 26,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF4A7FB5),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
