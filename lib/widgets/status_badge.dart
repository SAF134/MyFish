import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Status yang ditampilkan badge (DESIGN.md §7).
enum DeviceStatus { online, offline, pending }

/// Badge status: Terhubung (hijau), Terputus (abu), Menunggu (kuning).
///
/// Warna selalu disertai ikon + teks. Memakai `liveRegion` agar perubahan
/// diumumkan pembaca layar.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.onDark = false});

  final DeviceStatus status;

  /// Tampilan untuk latar gradien/gelap (latar putih semi-transparan).
  final bool onDark;

  (String, Color, IconData) get _spec => switch (status) {
    DeviceStatus.online => (
      'Terhubung',
      AppColors.success,
      Icons.check_circle_rounded,
    ),
    DeviceStatus.offline => (
      'Terputus',
      AppColors.offline,
      Icons.cloud_off_rounded,
    ),
    DeviceStatus.pending => (
      'Menunggu',
      AppColors.warning,
      Icons.schedule_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _spec;
    final caption = Theme.of(context).textTheme.labelMedium;

    return Semantics(
      liveRegion: true,
      label: 'Status: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: onDark ? AppColors.surface : color.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(label, style: caption?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
