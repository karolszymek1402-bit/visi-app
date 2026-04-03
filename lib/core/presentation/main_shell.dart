import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../navigation/app_router.dart';
import '../../features/finance/presentation/finance_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../l10n/app_localizations.dart';
import '../providers/connectivity_provider.dart';
import '../services/sync_service.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  // Offline banner state
  bool _isOffline = false;
  bool _isSyncing = false;
  Timer? _syncingTimer;

  static const List<Widget> _screens = [
    CalendarScreen(),
    ClientsScreen(),
    FinanceScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sync = ref.read(syncServiceProvider);
      if (sync == null) return;
      sync.syncAllClients().catchError((_) {});
      sync.syncAllVisits().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _syncingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reactively track connectivity changes to drive the banner
    ref.listen<bool>(connectivityProvider, (prev, next) {
      final wasOffline = !(prev ?? true);
      final isNowOnline = next;

      if (!isNowOnline) {
        // Went offline
        setState(() {
          _isOffline = true;
          _isSyncing = false;
        });
        _syncingTimer?.cancel();
      } else if (isNowOnline && wasOffline) {
        // Just came back online → show syncing briefly
        setState(() {
          _isOffline = false;
          _isSyncing = true;
        });
        _syncingTimer?.cancel();
        _syncingTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isSyncing = false);
        });
      }
    });

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          _OfflineBanner(
            isOffline: _isOffline,
            isSyncing: _isSyncing,
            l10n: l10n,
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassNavBar(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.editClient),
              backgroundColor: const Color(0xFF2E5B8A),
              elevation: 4,
              child: const Icon(Icons.person_add_rounded, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGlassNavBar() {
    final l10n = AppLocalizations.of(context)!;
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
                _navItem(0, Icons.calendar_today_rounded, l10n.navCalendar),
                _navItem(1, Icons.people_alt_rounded, l10n.navClients),
                _navItem(2, Icons.payments_rounded, l10n.navFinance),
                _navItem(3, Icons.settings_rounded, l10n.navSettings),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E5B8A).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF4A7FB5)
                    : Colors.white.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4A7FB5)
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Offline / Syncing Banner ─────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final bool isSyncing;
  final AppLocalizations l10n;

  const _OfflineBanner({
    required this.isOffline,
    required this.isSyncing,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final visible = isOffline || isSyncing;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -1.5),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOffline
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : const Color(0xFF4A7FB5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOffline
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                          : const Color(0xFF4A7FB5).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOffline
                            ? Icons.cloud_off_rounded
                            : Icons.sync_rounded,
                        color: isOffline
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF4A7FB5),
                        size: 15,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        isOffline
                            ? '${l10n.statusOffline} · ${l10n.statusOfflineHint}'
                            : l10n.statusSyncing,
                        style: TextStyle(
                          color: isOffline
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF4A7FB5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
