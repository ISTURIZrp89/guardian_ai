import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/clinical_formula.dart';

class CalculatorCard extends StatefulWidget {
  final ClinicalFormulaType type;
  final VoidCallback onTap;

  const CalculatorCard({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  State<CalculatorCard> createState() => _CalculatorCardState();
}

class _CalculatorCardState extends State<CalculatorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.bgCardHover : AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isPressed ? AppColors.borderFocused : AppColors.borderDefault,
              width: _isPressed ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.clinicalBlue.withAlpha(30),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        _iconFromString(type.iconData),
                        color: AppColors.clinicalBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SFPro',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  type.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontFamily: 'IBMPlexSans',
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.monitorGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.monitorGreen,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SFPro',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate;
      case 'child_care':
        return Icons.child_care;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'water_drop':
        return Icons.water_drop;
      case 'grain':
        return Icons.grain;
      case 'speed':
        return Icons.speed;
      case 'balance':
        return Icons.balance;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'psychology':
        return Icons.psychology;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'warning_amber':
        return Icons.warning_amber;
      default:
        return Icons.calculate;
    }
  }
}
