import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../../features/finance/presentation/finance_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = [
    const CalendarScreen(),
    const ClientsScreen(),
    const FinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: AppLocalizations.of(context)!.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: AppLocalizations.of(context)!.clients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: AppLocalizations.of(context)!.finance,
          ),
        ],
      ),
    );
  }
}
