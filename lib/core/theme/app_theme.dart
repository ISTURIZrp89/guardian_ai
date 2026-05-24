import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.clinicalBlue,
        secondary: AppColors.monitorGreen,
        error: AppColors.alertRed,
        surface: AppColors.bgCard,
        onPrimary: AppColors.deepBlack,
        onSecondary: AppColors.deepBlack,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: AppDimensions.fontSizeDisplay,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: AppDimensions.fontSizeXxl,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: AppDimensions.fontSizeXl,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeMd,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeSm,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: AppDimensions.fontSizeMd,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: AppDimensions.fontSizeSm,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
          fontWeight: FontWeight.w500,
          color: AppColors.textDisabled,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.clinicalBlue,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding: AppDimensions.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          borderSide: const BorderSide(
            color: AppColors.borderFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'SFPro',
        ),
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
          fontFamily: 'IBMPlexSans',
        ),
        errorStyle: const TextStyle(
          color: AppColors.alertRed,
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          backgroundColor: AppColors.clinicalBlue,
          foregroundColor: AppColors.deepBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: AppDimensions.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          foregroundColor: AppColors.clinicalBlue,
          side: const BorderSide(color: AppColors.clinicalBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: AppDimensions.fontSizeMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.clinicalBlue,
          textStyle: const TextStyle(
            fontFamily: 'SFPro',
            fontSize: AppDimensions.fontSizeSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCard,
        selectedColor: AppColors.clinicalBlue.withAlpha(51),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
        ),
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'IBMPlexSans',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.clinicalBlue,
        linearTrackColor: AppColors.bgCard,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.clinicalBlue;
          }
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.clinicalBlue.withAlpha(77);
          }
          return AppColors.bgCard;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.clinicalBlue,
        inactiveTrackColor: AppColors.bgCard,
        thumbColor: AppColors.clinicalBlue,
        overlayColor: AppColors.clinicalBlue,
      ),
    );
  }
}
