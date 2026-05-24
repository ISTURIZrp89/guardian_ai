import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  double get topPadding => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<T?> showAppDialog<T>({
    required String title,
    required Widget content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            ),
          if (confirmText != null)
            ElevatedButton(
              onPressed: () {
                onConfirm?.call();
                Navigator.pop(context);
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }
}

extension PaddingExtensions on num {
  Widget get gapW => Gap(toDouble());
  Widget get gapH => Gap(toDouble());
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: toDouble());
}
