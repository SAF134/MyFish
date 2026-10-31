import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Tema Material 3 MyFish (mode terang saja di v1.0.0).
abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryTint,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.primaryTint,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.success,
      onTertiary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.surfaceAlt,
      surfaceContainer: AppColors.surfaceAlt,
      surfaceContainerHigh: AppColors.surfaceAlt,
      surfaceContainerHighest: AppColors.surfaceAlt,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: AppColors.primaryDark,
    );

    final textTheme = AppTypography.textTheme;

    final focusBorder = const OutlineInputBorder(
      borderRadius: AppRadius.inputAll,
      borderSide: BorderSide(
        color: AppColors.primary,
        width: AppSizes.focusOutline,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fallback,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      focusColor: AppColors.primaryTint,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        errorStyle: textTheme.labelSmall?.copyWith(color: AppColors.error),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: focusBorder,
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppSizes.focusOutline,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.primaryDark,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          iconSize: AppSizes.icon,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.onPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetAll),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primaryTint,
        labelStyle: textTheme.labelMedium,
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.chip)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.offline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceAlt,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
