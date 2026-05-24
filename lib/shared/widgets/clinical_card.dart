import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

class ClinicalCard extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool gradientAccent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? borderColor;

  const ClinicalCard({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.icon,
    this.gradientAccent = false,
    this.onTap,
    this.padding,
    this.height,
    this.borderColor,
  });

  @override
  State<ClinicalCard> createState() => _ClinicalCardState();
}

class _ClinicalCardState extends State<ClinicalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: widget.borderColor ?? AppColors.borderDefault,
          ),
          gradient: widget.gradientAccent
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bgCard,
                    Color(0xFF1A2835),
                  ],
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            onTap: widget.onTap != null
                ? () {
                    _controller.forward().then((_) => _controller.reverse());
                    widget.onTap!();
                  }
                : null,
            splashColor: AppColors.clinicalBlue.withAlpha(30),
            highlightColor: AppColors.clinicalBlue.withAlpha(15),
            child: Padding(
              padding: widget.padding ?? AppDimensions.cardPadding,
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    12.gapW,
                  ],
                  if (widget.icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.clinicalBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: AppColors.clinicalBlue,
                        size: AppDimensions.iconSizeSmall,
                      ),
                    ),
                    12.gapW,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: const TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: AppDimensions.fontSizeMd,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (widget.subtitle != null) ...[
                          4.gapH,
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: AppDimensions.fontSizeXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    12.gapW,
                    widget.trailing!,
                  ],
                  if (widget.onTap != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textDisabled,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
