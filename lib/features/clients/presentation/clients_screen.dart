import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/client.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/client_tile.dart';

// ─── Screen ──────────────────────────────────────────────────────────────────

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Client> _filter(List<Client> clients) {
    if (_query.isEmpty) return clients;
    return clients.where((c) {
      return c.name.toLowerCase().contains(_query) ||
          (c.phone?.toLowerCase().contains(_query) ?? false) ||
          (c.email?.toLowerCase().contains(_query) ?? false) ||
          (c.address?.toLowerCase().contains(_query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Text(
          l10n.clientsDatabase,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        // Pasek wyszukiwania osadzony w AppBar.bottom
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchBar(
              controller: _searchCtrl,
              isDark: isDark,
              hint: l10n.clientName,
            ),
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      body: clientsAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (all) {
          final clients = _filter(all);
          if (all.isEmpty) return _EmptyState(l10n: l10n, noResults: false);
          if (clients.isEmpty) {
            return _EmptyState(l10n: l10n, noResults: true, query: _query);
          }
          return _ClientList(clients: clients);
        },
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hint;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'Szukaj klientów…',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.accent,
              size: 22,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: controller.clear,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.elevatedDark.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Client List ─────────────────────────────────────────────────────────────

class _ClientList extends StatelessWidget {
  final List<Client> clients;
  const _ClientList({required this.clients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: clients.length,
      itemBuilder: (context, i) => ClientTile(client: clients[i]),
    );
  }
}

// ─── Empty / Loading / Error states ─────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Ładowanie klientów…',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool noResults;
  final String? query;

  const _EmptyState({
    required this.l10n,
    required this.noResults,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              noResults
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 72,
              color: secondaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            Text(
              noResults ? 'Brak wyników dla "$query"' : l10n.noClients,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              noResults
                  ? 'Spróbuj innej frazy lub wyczyść wyszukiwanie.'
                  : 'Dodaj pierwszego klienta klikając przycisk + w prawym dolnym rogu.',
              style: TextStyle(fontSize: 14, color: secondaryColor),
              textAlign: TextAlign.center,
            ),
            if (!noResults) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.editClient),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Dodaj klienta'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
