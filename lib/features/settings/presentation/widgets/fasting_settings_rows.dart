import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class FastingSwitchRow extends StatelessWidget {
  const FastingSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: enabled
                ? AppColors.textWhite
                : AppColors.textWhite.withValues(alpha: 0.55),
            fontSize: 16,
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.accent,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
