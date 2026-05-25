import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

class ClinicalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool loading;
  final bool disabled;
  final bool gradient;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const ClinicalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    this.loading = false,
    this.disabled = false,
    this.gradient = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = AppDimensions.buttonHeight,
    this.borderRadius = AppDimensions.cardRadiusSmall,
    this.padding,
  });

  @override
  State<ClinicalButton> createState() => _ClinicalButtonState();
}

class _ClinicalButtonState extends State<ClinicalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.loading;
    final effectiveBg = widget.backgroundColor ?? AppColors.clinicalBlue;
    final effectiveFg = widget.foregroundColor ?? AppColors.deepBlack;

    final child = SizedBox(
      height: widget.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: isDisabled
              ? null
              : () {
                  setState(() => _pressed = true);
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) setState(() => _pressed = false);
                  });
                  widget.onPressed!();
                },
          splashColor: AppColors.textPrimary.withAlpha(30),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: widget.gradient && !isDisabled
                  ? AppColors.clinicalGradient
                  : null,
              color: !widget.gradient && !isDisabled
                  ? effectiveBg
                  : isDisabled
                      ? AppColors.bgCardHover
                      : null,
              border: isDisabled
                  ? Border.all(color: AppColors.borderDefault)
                  : null,
              boxShadow: _pressed && !isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: effectiveBg.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            transform: _pressed ? Matrix4.translationValues(0, 1, 0) : null,
            child: Padding(
              padding:
                  widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
              child: widget.loading
                  ? _buildShimmer(effectiveFg)
                  : Row(
                      mainAxisSize: widget.fullWidth
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: isDisabled
                                ? AppColors.textDisabled
                                : effectiveFg,
                            size: AppDimensions.iconSizeSmall,
                          ),
                          8.gapW,
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: AppDimensions.fontSizeMd,
                            fontWeight: FontWeight.w600,
                            color: isDisabled
                                ? AppColors.textDisabled
                                : effectiveFg,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (!widget.fullWidth) return child;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: child,
    );
  }

  Widget _buildShimmer(Color baseColor) {
    return Shimmer.fromColors(
      baseColor: baseColor.withAlpha(100),
      highlightColor: baseColor.withAlpha(50),
      child: Container(
        width: 120,
        height: 16,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
