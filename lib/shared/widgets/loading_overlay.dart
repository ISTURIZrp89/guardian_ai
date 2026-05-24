import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    this.message,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isLoading ? 1.0 : 0.0,
              child: Container(
                color: backgroundColor ?? AppColors.bgOverlay,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: indicatorColor ?? AppColors.clinicalBlue,
                        ),
                      ),
                      if (message != null) ...[
                        16.gapH,
                        Text(
                          message!,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: AppDimensions.fontSizeSm,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
