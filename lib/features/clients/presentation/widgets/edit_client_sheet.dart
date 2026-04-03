import 'package:flutter/material.dart';
import '../../../../core/models/client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'client_form_body.dart';

/// Formularz klienta osadzony w BottomSheet (używany przez FAB "Dodaj klienta").
///
/// Pełna logika formularza żyje w [ClientFormBody] — ten widget dodaje
/// tylko dekorację blachy (zaokrąglenie, drag handle, kolor tła).
class EditClientSheet extends StatelessWidget {
  final Client? client;
  const EditClientSheet({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Tytuł
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4),
            child: Text(
              client == null ? l10n.newClient : l10n.editClient,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),

          // Formularz
          Flexible(
            child: ClientFormBody(
              client: client,
              onClose: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
