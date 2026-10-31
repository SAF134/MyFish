import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografi Plus Jakarta Sans (cadangan Inter/Roboto) — DESIGN.md §3.
abstract final class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';
  static const List<String> fallback = ['Inter', 'Roboto'];

  static TextStyle _style(double size, double line, FontWeight weight) =>
      TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fallback,
        fontSize: size,
        height: line / size,
        fontWeight: weight,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        color: AppColors.text,
      );

  /// Display angka 40/48 700.
  static final TextStyle display = _style(40, 48, FontWeight.w700);

  /// Title 22/30 700.
  static final TextStyle title = _style(22, 30, FontWeight.w700);

  /// Heading 18/26 600.
  static final TextStyle heading = _style(18, 26, FontWeight.w600);

  /// Body 14/20 400.
  static final TextStyle body = _style(14, 20, FontWeight.w400);

  /// Button 15/20 600.
  static final TextStyle button = _style(15, 20, FontWeight.w600);

  /// Caption 12/16 500.
  static final TextStyle caption = _style(12, 16, FontWeight.w500);

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: title,
    headlineMedium: title,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: heading,
    titleSmall: button,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption.copyWith(color: AppColors.textMuted),
    labelLarge: button,
    labelMedium: caption,
    labelSmall: caption,
  );
}
