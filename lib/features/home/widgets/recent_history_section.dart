import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Bagian 5 Riwayat Pakan Terakhir di Beranda.
class RecentHistorySection extends StatelessWidget {
  const RecentHistorySection({super.key, required this.history});

  final List<HistoryItem> history;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayList = history.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Riwayat Pakan Terakhir',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Text(
                '${displayList.length} Terbaru',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (displayList.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum ada riwayat pakan',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aktivitas pakan otomatis dan manual akan tampil di sini.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < displayList.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _RecentHistoryItemCard(item: displayList[i]),
              ],
            ],
          ),
      ],
    );
  }
}

class _RecentHistoryItemCard extends StatelessWidget {
  const _RecentHistoryItemCard({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAuto = item.isAuto;

    final methodBg = isAuto ? AppColors.primaryTint : const Color(0xFFFFF3E0);
    final methodTextColor =
        isAuto ? AppColors.primaryDark : const Color(0xFFE65100);
    final methodBorderColor = isAuto
        ? AppColors.primaryLight.withValues(alpha: 0.3)
        : const Color(0xFFFFB74D);
    final methodIcon =
        isAuto ? Icons.schedule_rounded : Icons.touch_app_rounded;
    final methodLabel = isAuto ? 'Otomatis' : 'Manual';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 280;

        if (isNarrow) {
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: methodBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: methodBorderColor, width: 1.0),
                  ),
                  child: Icon(methodIcon, size: 16, color: methodTextColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatTime(item.timestamp),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        DateFormatter.formatDate(item.timestamp),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: methodBg,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        border:
                            Border.all(color: methodBorderColor, width: 0.8),
                      ),
                      child: Text(
                        methodLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: methodTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lvl ${item.level}',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              // Icon lingkaran metode
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: methodBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: methodBorderColor, width: 1.0),
                ),
                child: Icon(methodIcon, size: 20, color: methodTextColor),
              ),
              const SizedBox(width: AppSpacing.md),

              // Waktu & Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatTime(item.timestamp),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      DateFormatter.formatDate(item.timestamp),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Chip Metode
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: methodBg,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: methodBorderColor, width: 0.8),
                ),
                child: Text(
                  methodLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: methodTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              // Chip Level Takaran
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  'Lvl ${item.level} (${item.durationSec.toStringAsFixed(1)}s)',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
