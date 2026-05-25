import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PinDotWidget extends StatefulWidget {
  final int pinLength;
  final int currentLength;
  final bool hasError;

  const PinDotWidget({
    super.key,
    this.pinLength = 6,
    this.currentLength = 0,
    this.hasError = false,
  });

  @override
  State<PinDotWidget> createState() => _PinDotWidgetState();
}

class _PinDotWidgetState extends State<PinDotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void didUpdateWidget(PinDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeController.isAnimating
            ? sin(_shakeAnimation.value * pi * 4) * 8
            : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.pinLength, (index) {
          final isFilled = index < widget.currentLength;
          final isError = widget.hasError;
          return _buildDot(isFilled, isError, index);
        }),
      ),
    );
  }

  Widget _buildDot(bool isFilled, bool isError, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? AppColors.alertRed.withAlpha(40)
            : isFilled
                ? AppColors.clinicalBlue
                : Colors.transparent,
        border: Border.all(
          color: isError
              ? AppColors.alertRed
              : isFilled
                  ? AppColors.clinicalBlue
                  : AppColors.borderDefault,
          width: isFilled ? 2 : 1.5,
        ),
        boxShadow: isFilled && !isError
            ? [
                BoxShadow(
                  color: AppColors.clinicalBlue.withAlpha(50),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isFilled && !isError
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
