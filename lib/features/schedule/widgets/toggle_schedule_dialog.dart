import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/app_button.dart';

/// Dialog konfirmasi pengaktifan atau penonaktifan jadwal pakan.
Future<bool> showToggleScheduleDialog(
  BuildContext context, {
  required String time,
  required bool enabled,
}) async {
  final action = enabled ? 'Aktifkan' : 'Nonaktifkan';
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        enabled
            ? Icons.check_circle_outline_rounded
            : Icons.pause_circle_outline_rounded,
        color: enabled ? AppColors.success : AppColors.warning,
        size: 32,
      ),
      title: Text('$action Jadwal?'),
      content: Text(
        enabled
            ? 'Jadwal pakan jam $time akan diaktifkan dan dijalankan otomatis oleh alat.'
            : 'Jadwal pakan jam $time akan dinonaktifkan sementara dan tidak dijalankan oleh alat.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Batal',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: action,
                variant: enabled
                    ? AppButtonVariant.primary
                    : AppButtonVariant.danger,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}
