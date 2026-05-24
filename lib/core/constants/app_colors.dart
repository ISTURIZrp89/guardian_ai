import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color deepBlack = Color(0xFF0B0F14);
  static const Color clinicalBlue = Color(0xFF3BA4FF);
  static const Color monitorGreen = Color(0xFF00D17A);
  static const Color alertRed = Color(0xFFFF4D4D);

  // Backgrounds
  static const Color bgPrimary = Color(0xFF0B0F14);
  static const Color bgSecondary = Color(0xFF141A21);
  static const Color bgCard = Color(0xFF1A212B);
  static const Color bgCardHover = Color(0xFF222B37);
  static const Color bgInput = Color(0xFF1E2631);
  static const Color bgOverlay = Color(0x80000000);

  // Text
  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8E9BB0);
  static const Color textDisabled = Color(0xFF4A5363);
  static const Color textClinical = Color(0xFF3BA4FF);

  // Borders
  static const Color borderDefault = Color(0xFF252E3A);
  static const Color borderFocused = Color(0xFF3BA4FF);
  static const Color borderError = Color(0xFFFF4D4D);

  // Status Colors
  static const Color statusStable = Color(0xFF00D17A);
  static const Color statusWarning = Color(0xFFFFB347);
  static const Color statusCritical = Color(0xFFFF4D4D);
  static const Color statusInfo = Color(0xFF3BA4FF);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF0D1219);
  static const Color surfaceCard = Color(0xFF1A212B);
  static const Color surfaceElevated = Color(0xFF222B37);

  // Gradients
  static const LinearGradient clinicalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3BA4FF), Color(0xFF00D17A)],
  );

  static const LinearGradient alertGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D4D), Color(0xFFFF6B35)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B0F14), Color(0xFF141A21)],
  );
}
