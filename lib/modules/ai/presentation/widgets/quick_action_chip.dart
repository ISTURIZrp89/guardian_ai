import 'package:flutter/material.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';

class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.surfaceElevated
              : AppColors.bgInput,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          border: Border.all(
            color: isEnabled
                ? AppColors.borderDefault
                : AppColors.borderDefault.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSizeSmall,
              color: isEnabled
                  ? AppColors.textClinical
                  : AppColors.textDisabled,
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                fontSize: AppDimensions.fontSizeXs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
