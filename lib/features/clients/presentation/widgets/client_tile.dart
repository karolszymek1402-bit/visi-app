import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/client.dart';
import 'package:visi/app/router/app_router.dart';
import '../../../../core/providers/clients_provider.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'delete_confirmation_dialog.dart';
import 'rrule_badge.dart';

class ClientTile extends ConsumerWidget {
  final Client client;
  const ClientTile({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = client.color ?? AppColors.accent;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Slidable(
          key: ValueKey(client.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.22,
            children: [
              SlidableAction(
                onPressed: (_) => _deleteWithConfirmation(context, ref, l10n),
                backgroundColor: const Color(0xFFD93025),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: l10n.delete,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
            ],
          ),

          // ── Tile body ───────────────────────────────────────────────────────
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Material(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () =>
                      context.push(AppRoutes.editClient, extra: client),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // ── Hero Avatar ───────────────────────────────────────
                        Hero(
                          tag: 'client-avatar-${client.id}',
                          child: _ClientAvatar(
                            color: color,
                            name: client.name,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Info ──────────────────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (client.customRate != null)
                                    _Chip(
                                      icon: Icons.payments_outlined,
                                      label:
                                          '${client.customRate!.toStringAsFixed(0)} ${l10n.nok}/h',
                                      color: AppColors.accent,
                                    ),
                                  if (client.phone != null)
                                    _Chip(
                                      icon: Icons.phone_iphone_rounded,
                                      label: client.phone!,
                                      color: Colors.green,
                                    ),
                                  if (client.address != null)
                                    _Chip(
                                      icon: Icons.location_on_outlined,
                                      label: client.address!,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                ],
                              ),
                              if (client.recurrencePattern != null) ...[
                                const SizedBox(height: 6),
                                RRuleBadge(rrule: client.recurrencePattern!),
                              ],
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Delete confirmation ────────────────────────────────────────────────────

  Future<void> _deleteWithConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: l10n.deleteClient,
      message: l10n.deleteClientConfirm(client.name),
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(clientsProvider.notifier).removeClient(client.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSave(error.toString()))),
      );
    }
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _ClientAvatar extends StatelessWidget {
  final Color color;
  final String name;

  const _ClientAvatar({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

