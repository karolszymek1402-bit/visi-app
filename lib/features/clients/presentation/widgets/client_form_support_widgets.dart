import 'package:flutter/material.dart';

import 'package:visi/app/theme/app_theme.dart';

class ClientFormSectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const ClientFormSectionHeader({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              thickness: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Кругла кнопка дії (+/-) поруч із текстовим полем.
class ClientFormActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const ClientFormActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: enabled ? color : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: IconButton(
          icon: Icon(icon, size: 20),
          color: enabled ? color : Colors.grey,
          onPressed: enabled ? onTap : null,
        ),
      ),
    );
  }
}

class ClientFormStepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const ClientFormStepButton({
    super.key,
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
