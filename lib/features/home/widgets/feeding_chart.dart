import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Data pakan per hari untuk chart 7 hari.
class DayFeedingData {
  const DayFeedingData({
    required this.date,
    required this.count,
    required this.isToday,
  });

  final DateTime date;
  final int count;
  final bool isToday;

  String get dayLabel => DateFormatter.shortDay(date.weekday);
  String get fullDayName => DateFormatter.fullDay(date.weekday);
}

/// Widget Grafik Pakan 7 Hari menggunakan fl_chart (DESIGN.md).
class FeedingChart extends StatelessWidget {
  const FeedingChart({super.key, required this.history, this.referenceDate});

  final List<HistoryItem> history;

  /// Tanggal acuan untuk pengujian deterministik (default: DateTime.now()).
  final DateTime? referenceDate;

  List<DayFeedingData> _aggregate7Days() {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = <DayFeedingData>[];
    for (var i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final count = history.where((item) {
        final d = item.timestamp;
        return d.year == targetDate.year &&
            d.month == targetDate.month &&
            d.day == targetDate.day;
      }).length;

      days.add(DayFeedingData(date: targetDate, count: count, isToday: i == 0));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayData = _aggregate7Days();

    final maxCount = dayData.map((d) => d.count).fold<int>(0, max);
    final totalFeeding = dayData
        .map((d) => d.count)
        .fold<int>(0, (a, b) => a + b);
    final double maxY = max(4.0, (maxCount + 1).toDouble());

    final summary = dayData
        .map((d) => '${d.fullDayName} ${d.count} kali')
        .join(', ');

    return AppCard(
      semanticLabel: 'Grafik pakan 7 hari terakhir: $summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Grafik Pakan 7 Hari',
                  style: textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  'Total: $totalFeeding kali',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AspectRatio(
            aspectRatio: 1.7,
            child: Semantics(
              excludeSemantics: true,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.text,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = dayData[group.x];
                        return BarTooltipItem(
                          '${data.fullDayName}\n${data.count} kali',
                          textTheme.bodySmall!.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: maxY > 6 ? 2 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt().toString(),
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dayData.length) {
                            return const SizedBox.shrink();
                          }
                          final item = dayData[index];
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              item.dayLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: item.isToday
                                    ? AppColors.primaryDark
                                    : AppColors.textMuted,
                                fontWeight: item.isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 6 ? 2 : 1,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: AppColors.surfaceAlt,
                      strokeWidth: 1.2,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(dayData.length, (index) {
                    final item = dayData[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.count.toDouble(),
                          color: item.isToday
                              ? AppColors.primaryDark
                              : AppColors.primaryTint,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          if (totalFeeding == 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Belum ada data pakan 7 hari terakhir',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
