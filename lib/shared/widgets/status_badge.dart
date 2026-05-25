import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

enum BadgeStatus { stable, warning, critical, info }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String label;
  final bool showDot;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.showDot = true,
    this.fontSize = AppDimensions.fontSizeXs,
    this.padding,
  });

  Color get _color {
    switch (status) {
      case BadgeStatus.stable:
        return AppColors.statusStable;
      case BadgeStatus.warning:
        return AppColors.statusWarning;
      case BadgeStatus.critical:
        return AppColors.statusCritical;
      case BadgeStatus.info:
        return AppColors.statusInfo;
    }
  }

  Color get _bgColor => _color.withAlpha(26);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withAlpha(100),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            6.gapW,
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
