import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Bagian Jadwal Hari Ini di Beranda dengan desain adaptif khusus untuk 1, 2, dan 3 jadwal.
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
              final count = displayList.length;

              // 1. DESAIN KHUSUS 1 JADWAL (Horizontal Prominent Card)
              if (count == 1) {
                return _SingleScheduleCard(item: displayList.first);
              }

              final isNarrow = constraints.maxWidth < (count == 2 ? 260 : 320);

              // Jika layar sangat sempit, susun vertikal
              if (isNarrow) {
                return Column(
                  children: [
                    for (var i = 0; i < count; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      count == 2
                          ? _TwoScheduleCard(item: displayList[i])
                          : _MiniScheduleCard(item: displayList[i]),
                    ],
                  ],
                );
              }

              // 2. DESAIN KHUSUS 2 JADWAL (Balanced 2-Column Row)
              if (count == 2) {
                return Row(
                  children: [
                    Expanded(child: _TwoScheduleCard(item: displayList[0])),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _TwoScheduleCard(item: displayList[1])),
                  ],
                );
              }

              // 3. DESAIN KHUSUS 3 JADWAL (Sleek 3-Column Row)
              return Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
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

/// Kartu desain khusus jika HANYA ADA 1 JADWAL (Gaya Banner Prominen)
class _SingleScheduleCard extends StatelessWidget {
  const _SingleScheduleCard({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      semanticLabel:
          'Jadwal jam ${item.time}, Level ${item.level}, ${item.enabled ? "Aktif" : "Nonaktif"}',
      child: Row(
        children: [
          // Avatar Jam Pakan
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.enabled ? AppColors.primaryTint : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.enabled
                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
              boxShadow: item.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.alarm_rounded,
              size: 24,
              color: item.enabled ? AppColors.primaryDark : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Detail Jam dan Keterangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.time,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: item.enabled ? AppColors.text : AppColors.textMuted,
                      ),
                    ),
                    _buildStatusPill(textTheme, item.enabled),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
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
                      child: Text(
                        'Level ${item.level}',
                        style: textTheme.labelSmall?.copyWith(
                          color: item.enabled
                              ? AppColors.primaryDark
                              : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pemberian Pakan Otomatis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu desain khusus jika ADA 2 JADWAL (Gaya Dua Kolom Seimbang)
class _TwoScheduleCard extends StatelessWidget {
  const _TwoScheduleCard({required this.item});

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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.enabled ? AppColors.primaryTint : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.enabled
                        ? AppColors.primaryLight.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.alarm_rounded,
                  size: 18,
                  color: item.enabled ? AppColors.primaryDark : AppColors.textMuted,
                ),
              ),
              _buildStatusPill(textTheme, item.enabled),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.time,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.4,
              color: item.enabled ? AppColors.text : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: item.enabled ? AppColors.primaryTint : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: item.enabled
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.border,
                width: 0.8,
              ),
            ),
            child: Text(
              'Level ${item.level}',
              style: textTheme.labelSmall?.copyWith(
                color: item.enabled ? AppColors.primaryDark : AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu desain khusus jika ADA 3 JADWAL (Gaya Tiga Kolom Kompak)
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
              _buildStatusPill(textTheme, item.enabled, compact: true),
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
                fontSize: 17,
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

/// Helper status pill Aktif/Off
Widget _buildStatusPill(TextTheme textTheme, bool enabled, {bool compact = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 6 : 8,
      vertical: 2,
    ),
    decoration: BoxDecoration(
      color: enabled ? const Color(0xFFE8F5E9) : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: enabled ? const Color(0xFFA5D6A7) : AppColors.border,
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
            color: enabled ? AppColors.success : AppColors.offline,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          enabled ? 'Aktif' : 'Off',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.success : AppColors.offline,
          ),
        ),
      ],
    ),
  );
}
