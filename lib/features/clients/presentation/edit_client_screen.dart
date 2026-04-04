import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/client.dart';
import '../../../core/providers/clients_provider.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/client_form_body.dart';
import 'widgets/delete_confirmation_dialog.dart';

/// Pełnoekranowy formularz dodawania/edycji klienta.
///
/// Uruchamiany przez GoRouter z `/edit-client` z [SharedAxisTransition].
/// Jeśli [client] jest null — tryb dodawania nowego.
/// Jeśli [client] jest podany — tryb edycji z animowanym Hero awatarem.
class EditClientScreen extends ConsumerWidget {
  final Client? client;
  const EditClientScreen({super.key, this.client});

  bool get _isNew => client == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final color = client?.color ?? AppColors.accent;
    final initial = client?.name.isNotEmpty == true
        ? client!.name[0].toUpperCase()
        : '+';

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Scaffold(
          appBar: AppBar(
        // ── Hero Avatar — morphuje się z kafelka na liście ──────────────────
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Hero(
            tag: _isNew ? 'new-client-avatar' : 'client-avatar-${client!.id}',
            // flightShuttleBuilder utrzymuje styl awatara podczas animacji Hero
            flightShuttleBuilder: (ctx, animation, direction, from, to) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(
                      alpha: 0.1 + 0.05 * animation.value,
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _isNew ? l10n.newClient : l10n.editClient,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(l10n.commonCancel),
            ),
            if (!_isNew)
              IconButton(
                tooltip: l10n.deleteClient,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _handleDelete(context, ref, l10n),
              ),
          ],
        elevation: 0,
        scrolledUnderElevation: 0,
        // Subtelny akcent na tle AppBara w ciemnym motywie
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.backgroundLight,
      ),
          body: ClientFormBody(
            client: client,
            onClose: context.pop,
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final existingClient = client;
    if (existingClient == null) return;

    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: l10n.deleteClient,
      message: l10n.deleteClientConfirm(existingClient.name),
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(clientsProvider.notifier).removeClient(existingClient.id);
      if (!context.mounted) return;
      context.pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSave(error.toString()))),
      );
    }
  }
}
