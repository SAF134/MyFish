import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Jenis snackbar (DESIGN.md §7: sukses, error, info — muncul 3 dtk).
enum SnackType { success, error, info }

/// Helper snackbar seragam.
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
  }) {
    final (color, icon) = switch (type) {
      SnackType.success => (AppColors.success, Icons.check_circle_rounded),
      SnackType.error => (AppColors.error, Icons.error_rounded),
      SnackType.info => (AppColors.text, Icons.info_rounded),
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: AppDurations.snackbar,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: AppColors.onPrimary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackType.info);
}
