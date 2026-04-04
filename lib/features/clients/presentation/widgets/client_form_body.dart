import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/client.dart';
import '../../../../core/providers/clients_provider.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../features/finance/presentation/providers/finance_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'client_transaction_item.dart';
import 'client_form_support_widgets.dart';
import 'day_selector.dart';
import 'visi_color_picker.dart';

/// Kompletny formularz dodawania/edycji klienta.
///
/// Bezstanowy widok danych — może być osadzony zarówno w [BottomSheet]
/// jak i w pełnoekranowym [Scaffold]. Wywołuje [onClose] po zapisaniu.
class ClientFormBody extends ConsumerStatefulWidget {
  final Client? client;

  /// Wywołany po udanym zapisie — rodzic decyduje jak zamknąć.
  final VoidCallback onClose;

  const ClientFormBody({
    super.key,
    this.client,
    required this.onClose,
  });

  @override
  ConsumerState<ClientFormBody> createState() => _ClientFormBodyState();
}

class _ClientFormBodyState extends ConsumerState<ClientFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _messageCtrl;
  late final TextEditingController _noteCtrl;
  late Set<int> _selectedDays;
  late int _intervalWeeks;
  late int _selectedColorValue;
  late TimeOfDay _selectedTime;
  late int _durationMinutes;

  bool _isSaving = false;
  bool _allowPop = false;

  bool get _isNew => widget.client == null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _rateCtrl = TextEditingController(
      text: c?.customRate != null ? c!.customRate!.toStringAsFixed(0) : '',
    );
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _messageCtrl = TextEditingController(text: c?.smsTemplate ?? '');
    _noteCtrl = TextEditingController(text: c?.notes ?? '');
    _selectedDays = DaySelector.daysFromRRule(c?.recurrencePattern);
    _intervalWeeks = _parseInterval(c?.recurrencePattern);
    _selectedColorValue =
        c?.colorValue ?? VisiColorPicker.presets[0].toARGB32();
    _selectedTime = TimeOfDay(
      hour: c?.defaultStartHour ?? 8,
      minute: c?.defaultStartMinute ?? 0,
    );
    _durationMinutes = c?.defaultDurationMinutes ?? 120;
  }

  static int _parseInterval(String? rrule) {
    if (rrule == null) return 1;
    final m = RegExp(r'INTERVAL=(\d+)').firstMatch(rrule);
    return m != null ? (int.tryParse(m.group(1)!) ?? 1) : 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _rateCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final rate = _rateCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_rateCtrl.text.trim());

      final client = Client(
        id: widget.client?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        customRate: rate,
        colorValue: _selectedColorValue,
        recurrencePattern:
            DaySelector.buildRRule(_selectedDays, _intervalWeeks),
        defaultStartHour: _selectedTime.hour,
        defaultDurationMinutes: _durationMinutes,
        defaultStartMinute: _selectedTime.minute,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        smsTemplate:
            _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
        notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        createdAt: widget.client?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(clientsProvider.notifier).addOrUpdateClient(client);
      widget.onClose();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _launchDialer() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final existingClient = widget.client;
    final clientTransactions = existingClient == null
        ? const []
        : ref.watch(financeTransactionsForClientProvider(existingClient.id));
    final clientLtv = existingClient == null
        ? 0.0
        : ref.watch(financeClientIncomeLtvProvider(existingClient.id));
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ltvValue = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 2,
    ).format(clientLtv).trim();
    final ltvText = l10n.financeAmountWithCurrency(ltvValue, l10n.financeCurrency);

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmDiscardAndPop(context, l10n);
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (existingClient != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.elevatedDark.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        existingClient.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.25),
                      ),
                      label: Text(
                        l10n.clientLtv(ltvText),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            // ── Sekcja: Podstawowe ──────────────────────────────────────────
            ClientFormSectionHeader(label: 'Dane podstawowe', isDark: isDark),

            // Nazwa (wymagana)
            TextFormField(
              controller: _nameCtrl,
              autofocus: _isNew,
              decoration: InputDecoration(
                labelText: '${l10n.clientName} *',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Podaj imię i nazwisko' : null,
            ),
            const SizedBox(height: 12),

            // Adres
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: l10n.addressOptional,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // ── Sekcja: Kontakt ─────────────────────────────────────────────
            ClientFormSectionHeader(label: 'Kontakt', isDark: isDark),

            // Telefon + przycisk dzwonienia
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumber,
                      prefixIcon:
                          const Icon(Icons.phone_iphone_rounded),
                      hintText: '+47 000 000 000',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 7) return 'Nieprawidłowy numer';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _phoneCtrl,
                  builder: (context, value, child) => ClientFormActionButton(
                    icon: Icons.call_rounded,
                    tooltip: 'Zadzwoń',
                    enabled: value.text.trim().isNotEmpty,
                    color: Colors.green,
                    onTap: _launchDialer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // E-mail + przycisk mailowania
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'jan@example.com',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!RegExp(
                        r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(v.trim())) {
                        return 'Nieprawidłowy adres e-mail';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _emailCtrl,
                  builder: (context, value, child) => ClientFormActionButton(
                    icon: Icons.send_rounded,
                    tooltip: 'Wyślij e-mail',
                    enabled: value.text.trim().isNotEmpty,
                    color: AppColors.accent,
                    onTap: _launchEmail,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Sekcja: Historia płatności ─────────────────────────────────
            if (existingClient != null) ...[
              ClientFormSectionHeader(
                label: l10n.clientPaymentHistory,
                isDark: isDark,
              ),
              if (clientTransactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.elevatedDark.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    l10n.clientNoPaymentHistory,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final transaction in clientTransactions.take(6)) ...[
                      ClientTransactionItem(transaction: transaction),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              const SizedBox(height: 20),
            ],

            // ── Sekcja: Stawka ──────────────────────────────────────────────
            ClientFormSectionHeader(label: 'Stawka i harmonogram', isDark: isDark),

            TextFormField(
              controller: _rateCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.rateNokH,
                prefixIcon: const Icon(Icons.payments_outlined),
                hintText: 'Puste = stawka domyślna',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final rate = double.tryParse(v.trim());
                if (rate == null) return 'Podaj liczbę';
                if (rate < 0) return 'Stawka nie może być ujemna';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kolor
            VisiColorPicker(
              selectedColorValue: _selectedColorValue,
              onColorSelected: (v) => setState(() => _selectedColorValue = v),
            ),
            const SizedBox(height: 16),

            // Cykl wizyt
            Text(
              l10n.visitCycle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 1, label: Text(l10n.oneWeek)),
                ButtonSegment(value: 2, label: Text(l10n.twoWeeks)),
              ],
              selected: {_intervalWeeks},
              onSelectionChanged: (v) =>
                  setState(() => _intervalWeeks = v.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(height: 16),

            // Dni tygodnia
            Text(
              l10n.workloadDays(_selectedDays.length),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ClientFormStepButton(
                  icon: Icons.remove,
                  enabled: _selectedDays.length > 1,
                  color: Color(_selectedColorValue),
                  onTap: () {
                    if (_selectedDays.length <= 1) return;
                    final sorted = _selectedDays.toList()..sort();
                    sorted.removeLast();
                    setState(() => _selectedDays = sorted.toSet());
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DaySelector(
                    selectedDays: _selectedDays,
                    activeColor: Color(_selectedColorValue),
                    onChanged: (d) => setState(() => _selectedDays = d),
                  ),
                ),
                const SizedBox(width: 8),
                ClientFormStepButton(
                  icon: Icons.add,
                  enabled: _selectedDays.length < 7,
                  color: Color(_selectedColorValue),
                  onTap: () {
                    if (_selectedDays.length >= 7) return;
                    for (final d in [1, 2, 3, 4, 5, 6, 7]) {
                      if (!_selectedDays.contains(d)) {
                        setState(() => _selectedDays = {..._selectedDays, d});
                        return;
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Godzina startu
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined, color: AppColors.accent),
              title: Text(l10n.startTime),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: Theme.of(ctx).colorScheme.copyWith(
                        primary: AppColors.accent,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),
            const SizedBox(height: 16),

            // Czas trwania
            Text(
              l10n.duration,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClientFormStepButton(
                  icon: Icons.remove,
                  enabled: _durationMinutes > 15,
                  color: AppColors.accent,
                  onTap: () => setState(() {
                    _durationMinutes =
                        (_durationMinutes - 15).clamp(15, 480);
                  }),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_durationMinutes ~/ 60}h'
                  '${_durationMinutes % 60 > 0 ? ' ${_durationMinutes % 60}min' : ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                ClientFormStepButton(
                  icon: Icons.add,
                  enabled: _durationMinutes < 480,
                  color: AppColors.accent,
                  onTap: () => setState(() {
                    _durationMinutes =
                        (_durationMinutes + 15).clamp(15, 480);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Sekcja: SMS & Notatki ───────────────────────────────────────
            ClientFormSectionHeader(label: 'SMS & Notatki', isDark: isDark),

            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.smsMessageContent,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.message_outlined),
                ),
                hintText: l10n.smsHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Notatki (multi-line)
            TextFormField(
              controller: _noteCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.clientNote,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.edit_note_rounded),
                ),
                hintText: l10n.clientNoteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // ── Save button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor:
                      AppColors.accent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isNew ? Icons.person_add_rounded : Icons.save_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isNew ? l10n.addClient : l10n.saveChanges,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscardAndPop(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final navigator = Navigator.of(context);
    if (!_hasUnsavedChanges()) {
      if (!mounted) return;
      setState(() => _allowPop = true);
      navigator.pop();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.commonDiscardChanges),
        content: Text(l10n.commonDiscardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDiscardChanges),
          ),
        ],
      ),
    );

    if (discard != true || !mounted) return;
    setState(() => _allowPop = true);
    navigator.pop();
  }

  bool _hasUnsavedChanges() {
    final existing = widget.client;
    if (existing == null) {
      return _nameCtrl.text.trim().isNotEmpty ||
          _addressCtrl.text.trim().isNotEmpty ||
          _rateCtrl.text.trim().isNotEmpty ||
          _phoneCtrl.text.trim().isNotEmpty ||
          _emailCtrl.text.trim().isNotEmpty ||
          _messageCtrl.text.trim().isNotEmpty ||
          _noteCtrl.text.trim().isNotEmpty;
    }

    final existingRate = existing.customRate;
    final currentRate = _rateCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_rateCtrl.text.trim());

    return _nameCtrl.text.trim() != existing.name ||
        (_addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim()) !=
            existing.address ||
        currentRate != existingRate ||
        (_phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim()) !=
            existing.phone ||
        (_emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim()) !=
            existing.email ||
        (_messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim()) !=
            existing.smsTemplate ||
        (_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()) !=
            existing.notes ||
        _selectedColorValue != existing.colorValue ||
        _intervalWeeks != _parseInterval(existing.recurrencePattern) ||
        _selectedDays.length !=
            DaySelector.daysFromRRule(existing.recurrencePattern).length ||
        !_selectedDays.containsAll(
          DaySelector.daysFromRRule(existing.recurrencePattern),
        ) ||
        _selectedTime.hour != existing.defaultStartHour ||
        _selectedTime.minute != existing.defaultStartMinute ||
        _durationMinutes != existing.defaultDurationMinutes;
  }
}
