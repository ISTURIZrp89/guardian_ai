import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

class ClinicalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ClinicalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.appBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgPrimary,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showBack)
            leading ??
                IconButton(
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                  ),
                  color: foregroundColor ?? AppColors.textPrimary,
                  splashRadius: 20,
                )
          else
            16.gapW,
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: AppDimensions.fontSizeLg,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          if (showBack) 16.gapW,
        ],
      ),
    );
  }
}
