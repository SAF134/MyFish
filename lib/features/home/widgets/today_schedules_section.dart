import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Bagian Jadwal Hari Ini di Beranda.
class TodaySchedulesSection extends StatelessWidget {
  const TodaySchedulesSection({
    super.key,
    required this.schedules,
    this.onViewAll,
  });

  final List<ScheduleItem> schedules;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayList = schedules.take(3).toList();

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
                  'Jadwal Hari Ini',
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
                '${schedules.length} Jadwal',
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
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
                    Icons.schedule_rounded,
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
                        'Belum ada jadwal pakan',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jadwal pakan otomatis dapat diatur pada menu tab Jadwal.',
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 280;
              if (isNarrow) {
                return Column(
                  children: [
                    for (var i = 0; i < displayList.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _MiniScheduleCard(item: displayList[i]),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < displayList.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _MiniScheduleCard(item: displayList[i])),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }
}

class _MiniScheduleCard extends StatelessWidget {
  const _MiniScheduleCard({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel:
          'Jadwal jam ${item.time}, Level ${item.level}, ${item.enabled ? "Aktif" : "Nonaktif"}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.enabled
                      ? AppColors.primaryTint
                      : AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: item.enabled ? AppColors.primaryDark : AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.enabled
                      ? const Color(0xFFE8F5E9)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.enabled
                        ? const Color(0xFFA5D6A7)
                        : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.enabled ? AppColors.success : AppColors.offline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.enabled ? 'Aktif' : 'Off',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.enabled ? AppColors.success : AppColors.offline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.time,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: item.enabled ? AppColors.text : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: item.enabled
                  ? AppColors.primaryTint
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: item.enabled
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.border,
                width: 0.8,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Lvl ${item.level}',
                style: textTheme.labelSmall?.copyWith(
                  color: item.enabled
                      ? AppColors.primaryDark
                      : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
