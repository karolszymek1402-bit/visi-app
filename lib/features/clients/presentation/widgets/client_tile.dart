import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/client.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/clients_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
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
                onPressed: (_) => _confirmDelete(context, ref, l10n),
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

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteDialog(
        name: client.name,
        onConfirm: () {
          Navigator.pop(ctx);
          ref.read(clientsProvider.notifier).deleteClient(client.id);
        },
        onCancel: () => Navigator.pop(ctx),
        l10n: l10n,
      ),
    );
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

// ─── Delete Dialog ────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String name;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final AppLocalizations l10n;

  const _DeleteDialog({
    required this.name,
    required this.onConfirm,
    required this.onCancel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor:
          isDark ? AppColors.elevatedDark : Colors.white,
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFD93025).withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFD93025),
          size: 28,
        ),
      ),
      title: Text(l10n.deleteClient),
      content: Text(l10n.deleteClientConfirm(name)),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD93025),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
