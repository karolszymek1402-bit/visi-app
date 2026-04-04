import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/finance/presentation/providers/finance_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.initialTransaction});

  final Transaction? initialTransaction;

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.income;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTransaction;
    if (initial != null) {
      _amountCtrl.text = initial.amount.toStringAsFixed(2);
      _categoryCtrl.text = initial.category;
      _noteCtrl.text = initial.note ?? '';
      _type = initial.type;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
        child: SafeArea(
          top: false,
          child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.addTransaction,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonCancel,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.initialTransaction?.visitId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.financeLinkedToVisit,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.financeAmountLabel,
                    hintText: l10n.financeAmountHint,
                  ),
                  validator: (value) {
                    final raw = value?.trim() ?? '';
                    if (raw.isEmpty) return l10n.amountRequired;
                    final parsed = double.tryParse(raw.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n.amountRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.financeTypeLabel),
                  items: [
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text(l10n.transactionIncome),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text(l10n.transactionExpense),
                    ),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (next) {
                          if (next != null) {
                            setState(() => _type = next);
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.financeCategoryLabel,
                    hintText: l10n.financeCategoryHint,
                  ),
                  validator: (value) {
                    if ((value?.trim().isEmpty ?? true)) {
                      return l10n.categoryRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.financeNoteLabel,
                    hintText: l10n.financeOptional,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_isSaving ? l10n.financeSaving : l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountCtrl.text.trim().replaceAll(',', '.'));
      final initial = widget.initialTransaction;
      final transaction = (initial != null)
          ? initial.copyWith(
              amount: amount,
              type: _type,
              category: _categoryCtrl.text.trim(),
              note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            )
          : Transaction(
              id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
              amount: amount,
              date: DateTime.now(),
              type: _type,
              category: _categoryCtrl.text.trim(),
              note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            );
      await ref
          .read(financeTransactionsProvider.notifier)
          .addTransaction(transaction);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(l10n.financeSaveFailed(error.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
