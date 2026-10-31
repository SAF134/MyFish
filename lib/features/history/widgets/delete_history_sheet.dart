import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/slide_confirm.dart';

/// Bottom sheet konfirmasi penghapusan riwayat dengan SlideConfirm (AGENTS.md aturan 1).
class DeleteHistorySheet extends StatelessWidget {
  const DeleteHistorySheet({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final HistoryItem item;
  final Future<void> Function() onDelete;

  static Future<void> show(
    BuildContext context, {
    required HistoryItem item,
    required Future<void> Function() onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DeleteHistorySheet(item: item, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeStr = DateFormatter.formatDateTime(item.timestamp);
    final isAuto = item.method == 'auto';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hapus Riwayat Pakan?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Tutup',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Catatan pemberian pakan ini akan dihapus permanen dari sistem.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ringkasan detail item yang akan dihapus
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isAuto ? Icons.alarm_rounded : Icons.touch_app_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeStr,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Metode: ${isAuto ? "Otomatis" : "Manual"} · Level ${item.level} (${item.durationSec} dtk)',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Tombol geser konfirmasi bahaya (SlideConfirm)
          SlideConfirm(
            label: 'Geser untuk hapus riwayat',
            variant: SlideConfirmVariant.danger,
            loadingLabel: 'Menghapus…',
            onConfirm: () async {
              await onDelete();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
