import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Kartu item riwayat pakan (DESIGN.md §6).
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.item,
    required this.canDelete,
    required this.onDelete,
  });

  final HistoryItem item;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeStr = DateFormatter.formatTime(item.timestamp);
    final isAuto = item.method == 'auto';
    final methodLabel = isAuto ? 'Otomatis' : 'Manual';

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      semanticLabel:
          'Riwayat jam $timeStr, Metode $methodLabel, Level ${item.level}, Durasi ${item.durationSec} detik',
      child: Row(
        children: [
          // Jam besar
          Text(
            timeStr,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Chip Metode (Otomatis / Manual)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isAuto ? AppColors.primaryTint : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: isAuto ? AppColors.primaryLight : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAuto ? Icons.alarm_rounded : Icons.touch_app_rounded,
                  size: 14,
                  color: isAuto ? AppColors.primaryDark : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  methodLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: isAuto ? AppColors.primaryDark : AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Chip Dosis (Level X)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(
              'Lvl ${item.level}',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),

          // Ikon Hapus
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: canDelete ? AppColors.error : AppColors.offline,
              size: 22,
            ),
            tooltip: canDelete
                ? 'Hapus riwayat jam $timeStr'
                : 'Hapus dinonaktifkan saat offline',
            onPressed: canDelete ? onDelete : null,
          ),
        ],
      ),
    );
  }
}
