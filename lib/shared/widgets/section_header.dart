import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: AppDimensions.md,
            right: AppDimensions.md,
            top: AppDimensions.md,
            bottom: AppDimensions.sm,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: AppDimensions.fontSizeLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.clinicalBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: AppDimensions.fontSizeXs,
                        fontWeight: FontWeight.w600,
                        color: AppColors.clinicalBlue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (showDivider) ...[
            8.gapH,
            const Divider(
              color: AppColors.borderDefault,
              thickness: 0.5,
              height: 1,
            ),
          ],
        ],
      ),
    );
  }
}
