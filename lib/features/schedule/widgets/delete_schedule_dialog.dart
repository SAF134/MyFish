import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/app_button.dart';

/// Dialog konfirmasi penghapusan jadwal pakan (DESIGN.md §5).
Future<bool> showDeleteScheduleDialog(
  BuildContext context, {
  required String time,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.error,
        size: 32,
      ),
      title: const Text('Hapus Jadwal?'),
      content: Text(
        'Jadwal pakan jam $time akan dihapus dan tidak lagi dijalankan oleh alat.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textMuted),
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
              child: AppButton.danger(
                label: 'Hapus',
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
