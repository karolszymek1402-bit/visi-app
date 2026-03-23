import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/clients_provider.dart';
import 'day_selector.dart';
import 'visi_color_picker.dart';

/// Formularz edycji/dodawania klienta — BottomSheet.
class EditClientSheet extends ConsumerStatefulWidget {
  final Client? client;
  const EditClientSheet({super.key, this.client});

  @override
  ConsumerState<EditClientSheet> createState() => _EditClientSheetState();
}

class _EditClientSheetState extends ConsumerState<EditClientSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _phoneController;
  late final TextEditingController _messageController;
  late final TextEditingController _noteController;
  late Set<int> _selectedDays;
  late int _intervalWeeks;
  late int _selectedColorValue;
  late TimeOfDay _selectedTime;
  late int _durationMinutes;

  bool get _isNew => widget.client == null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _rateCtrl = TextEditingController(
      text: c != null ? c.defaultRate.toStringAsFixed(0) : '',
    );
    _phoneController = TextEditingController(text: c?.phoneNumber ?? '');
    _messageController = TextEditingController(text: c?.smsTemplate ?? '');
    _noteController = TextEditingController(text: c?.note ?? '');
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
    final match = RegExp(r'INTERVAL=(\d+)').firstMatch(rrule);
    return match != null ? (int.tryParse(match.group(1)!) ?? 1) : 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _rateCtrl.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isNew ? 'Nowy klient' : 'Edytuj klienta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),

            // Nazwa
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nazwa klienta',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Adres
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Adres (opcjonalnie)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Numer telefonu
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Numer telefonu',
                prefixIcon: Icon(Icons.phone_iphone_rounded),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // Treść wiadomości (Automatyczny SMS)
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Treść wiadomości do wysłania',
                prefixIcon: Icon(Icons.message_rounded),
                hintText: 'Cześć! Przypominam o wizycie...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Notatka o kliencie
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notatka o kliencie (opcjonalnie)',
                prefixIcon: Icon(Icons.edit_note_rounded),
                hintText: 'Np. Uczulenie na hybrydę, ulubiona kawa...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Stawka
            TextField(
              controller: _rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stawka (NOK/h)',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
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
              'Cykl wizyt',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 tydzień')),
                ButtonSegment(value: 2, label: Text('2 tygodnie')),
              ],
              selected: {_intervalWeeks},
              onSelectionChanged: (v) =>
                  setState(() => _intervalWeeks = v.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(height: 16),

            // Obciążenie
            Text(
              'Obciążenie: ${_selectedDays.length} dni/tyg.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _RoundButton(
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
                    onChanged: (days) => setState(() => _selectedDays = days),
                  ),
                ),
                const SizedBox(width: 8),
                _RoundButton(
                  icon: Icons.add,
                  enabled: _selectedDays.length < 7,
                  color: Color(_selectedColorValue),
                  onTap: () {
                    if (_selectedDays.length >= 7) return;
                    const order = [1, 2, 3, 4, 5, 6, 7];
                    for (final d in order) {
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
              title: const Text('Godzina rozpoczęcia'),
              trailing: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.purpleAccent,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedTime = picked);
                }
              },
            ),
            const SizedBox(height: 16),

            // Czas trwania
            Text(
              'Czas trwania',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(
                  icon: Icons.remove,
                  enabled: _durationMinutes > 15,
                  color: AppColors.primary,
                  onTap: () => setState(() {
                    _durationMinutes = (_durationMinutes - 15).clamp(15, 480);
                  }),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_durationMinutes ~/ 60}h ${_durationMinutes % 60 > 0 ? '${_durationMinutes % 60}min' : ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 16),
                _RoundButton(
                  icon: Icons.add,
                  enabled: _durationMinutes < 480,
                  color: AppColors.primary,
                  onTap: () => setState(() {
                    _durationMinutes = (_durationMinutes + 15).clamp(15, 480);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Przycisk zapisu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(_isNew ? Icons.person_add : Icons.save),
                label: Text(_isNew ? 'Dodaj klienta' : 'Zapisz zmiany'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final rate = double.tryParse(_rateCtrl.text.trim());

    if (name.isEmpty || rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj nazwę i prawidłową stawkę')),
      );
      return;
    }

    final client = Client(
      id: widget.client?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
      defaultRate: rate,
      colorValue: _selectedColorValue,
      recurrencePattern: DaySelector.buildRRule(_selectedDays, _intervalWeeks),
      defaultStartHour: _selectedTime.hour,
      defaultDurationMinutes: _durationMinutes,
      defaultStartMinute: _selectedTime.minute,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      smsTemplate: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    ref.read(clientsProvider.notifier).saveClient(client);
    Navigator.pop(context);
  }
}

// ─── Okrągły przycisk +/- ───

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? color : Colors.grey.shade300,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
