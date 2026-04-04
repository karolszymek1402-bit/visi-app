import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/settings/presentation/providers/settings_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.account_circle),
      tooltip: l10n.settingsAccount,
      onPressed: () =>
          _showAccountMenu(context, ref, l10n, _resolveCurrentEmail(ref)),
    );
  }

  String? _resolveCurrentEmail(WidgetRef ref) {
    try {
      return ref.read(authServiceProvider).currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  Future<void> _showAccountMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String? email,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsProvider).valueOrNull;
            final selectedCurrency = settings?.currencyCode ?? 'PLN';
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        email ?? l10n.settingsAccount,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          l10n.settingsCurrency,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: selectedCurrency,
                          items: const [
                            DropdownMenuItem(value: 'PLN', child: Text('PLN')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'NOK', child: Text('NOK')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            ref.read(settingsProvider.notifier).updateCurrency(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(l10n.settingsSignOut),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await ref.read(authProvider.notifier).signOut();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      l10n.authDeleteAccount,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _confirmDeleteAccount(context, ref, l10n);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.authDeleteAccount),
        content: Text(l10n.authDeleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.authDeleteAccount),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authProvider.notifier).deleteAccount();
    } on AuthRequiresRecentLoginException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authReauthenticateRequired)),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorAuth(error.toString()))),
      );
    }
  }
}
