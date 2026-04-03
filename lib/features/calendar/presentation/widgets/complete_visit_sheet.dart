import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/calendar_provider.dart';

class CompleteVisitSheet extends ConsumerStatefulWidget {
  final Visit visit;
  final Client client;
  final double? prefilledDurationHours;

  const CompleteVisitSheet({
    super.key,
    required this.visit,
    required this.client,
    this.prefilledDurationHours,
  });

  @override
  ConsumerState<CompleteVisitSheet> createState() => _CompleteVisitSheetState();
}

class _CompleteVisitSheetState extends ConsumerState<CompleteVisitSheet> {
  double _actualDurationInHours = 0.0;
  double _earnedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDurationHours != null) {
      // Snap do 15 min — inSeconds w timerze zapewnia właściwą granicę zaokrąglenia
      _actualDurationInHours =
          (widget.prefilledDurationHours! * 4).round() / 4.0;
      if (_actualDurationInHours < 0.25) _actualDurationInHours = 0.25;
    } else {
      // Domyślnie czas zaplanowany — używamy inSeconds dla spójnej precyzji
      final duration = widget.visit.scheduledEnd.difference(
        widget.visit.scheduledStart,
      );
      _actualDurationInHours = duration.inSeconds / 3600.0;
    }
    _calculateEarnings();
  }

  void _calculateEarnings() {
    // Zaokrąglenie do 2 miejsc dziesiętnych zapobiega akumulacji błędu float
    // customRate is nullable — fall back to 0 when not set per-client
    final raw = _actualDurationInHours * (widget.client.customRate ?? 0);
    setState(() {
      _earnedAmount = double.parse(raw.toStringAsFixed(2));
    });
  }

  /// Formatuje dziesiętne godziny jako "Xh Ymin".
  /// Obsługuje edge-case gdzie minuty zaokrąglają się do 60.
  String _formatHours(double decimalHours) {
    int hours = decimalHours.floor();
    int minutes = ((decimalHours - hours) * 60).round();
    if (minutes == 60) {
      hours++;
      minutes = 0;
    }
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Arkusz dopasuje się do zawartości
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nagłówek
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.completeVisit,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const CloseButton(color: AppColors.textSecondaryLight),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.client.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Stepper czasu trwania (+/- 15 min)
          Text(
            AppLocalizations.of(context)!.labelActualDuration,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: _actualDurationInHours > 0.25,
                onTap: () {
                  setState(() {
                    _actualDurationInHours = (_actualDurationInHours - 0.25)
                        .clamp(0.25, 12.0);
                  });
                  _calculateEarnings();
                },
              ),
              const SizedBox(width: 16),
              Text(
                _formatHours(_actualDurationInHours),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 16),
              _StepButton(
                icon: Icons.add,
                enabled: _actualDurationInHours < 12.0,
                onTap: () {
                  setState(() {
                    _actualDurationInHours = (_actualDurationInHours + 0.25)
                        .clamp(0.25, 12.0);
                  });
                  _calculateEarnings();
                },
              ),
            ],
          ),

          // Podsumowanie zarobków
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.labelEarned}:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_earnedAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.nok}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.clientOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Przycisk "Zakończ"
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Wywołujemy silnik domknięcia w Riverpodzie
                ref
                    .read(calendarProvider.notifier)
                    .completeVisit(
                      visitId: widget.visit.id,
                      actualDuration: _actualDurationInHours,
                      earnedAmount: _earnedAmount,
                    );
                Navigator.pop(context); // Zamykamy arkusz
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.primary : Colors.grey.shade300,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
