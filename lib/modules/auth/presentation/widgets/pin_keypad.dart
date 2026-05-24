import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';

class PinKeypad extends StatelessWidget {
  final void Function(String key)? onKeyPressed;

  const PinKeypad({
    super.key,
    this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onKeyPressed != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3'], isEnabled),
          12.gapH,
          _buildRow(['4', '5', '6'], isEnabled),
          12.gapH,
          _buildRow(['7', '8', '9'], isEnabled),
          12.gapH,
          _buildRow(['delete', '0', 'confirm'], isEnabled),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, bool isEnabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) => _buildKey(key, isEnabled)).toList(),
    );
  }

  Widget _buildKey(String key, bool isEnabled) {
    final isDelete = key == 'delete';
    final isConfirm = key == 'confirm';
    final isEmptyKey = key == '';

    if (isEmptyKey) {
      return const SizedBox(width: 80, height: 80);
    }

    return GestureDetector(
      onTap: isEnabled && !isConfirm ? () => onKeyPressed!(key) : null,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isDelete || isConfirm
              ? Colors.transparent
              : isEnabled
                  ? AppColors.bgCard
                  : AppColors.bgInput,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isEnabled
                ? AppColors.borderDefault
                : AppColors.borderDefault.withAlpha(80),
            width: 1,
          ),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: isEnabled
                      ? AppColors.textSecondary
                      : AppColors.textDisabled,
                  size: 26,
                )
              : isConfirm
                  ? Icon(
                      Icons.check_circle_outline,
                      color: isEnabled
                          ? AppColors.clinicalBlue
                          : AppColors.textDisabled,
                      size: 26,
                    )
                  : Text(
                      key,
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: AppDimensions.fontSizeXl,
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
        ),
      ),
    );
  }
}
