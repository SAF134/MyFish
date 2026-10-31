import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_card.dart';

/// Kartu jadwal pakan di tab Jadwal (DESIGN.md §6).
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final ScheduleItem item;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = item.enabled;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      semanticLabel:
          'Jadwal jam ${item.time}, Level ${item.level}, ${isEnabled ? "Aktif" : "Nonaktif"}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Jam & Level di kiri, Tombol On/Off Switch di pojok kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jam besar & chip level
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.time,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? AppColors.text : AppColors.textMuted,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.primaryTint
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(
                        color: isEnabled
                            ? AppColors.primaryLight.withValues(alpha: 0.3)
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Level ${item.level}',
                      style: textTheme.labelSmall?.copyWith(
                        color: isEnabled
                            ? AppColors.primaryDark
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Tombol On/Off Switch di pojok kanan
              Semantics(
                toggled: isEnabled,
                label: 'Status aktif jadwal jam ${item.time}',
                child: SizedBox(
                  width: AppSizes.minTouch,
                  height: AppSizes.minTouch,
                  child: Center(
                    child: Switch(
                      value: isEnabled,
                      onChanged: onToggle,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Baris Bawah: Status teks di kiri, Tombol Ubah & Hapus di kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isEnabled ? AppColors.success : AppColors.offline,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isEnabled ? 'Aktif setiap hari' : 'Dinonaktifkan',
                    style: textTheme.bodySmall?.copyWith(
                      color: isEnabled ? AppColors.success : AppColors.offline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Aksi Tombol Ubah & Hapus dengan hitbox terisolasi >= 48dp
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    tooltip: 'Ubah jadwal jam ${item.time}',
                    onPressed: onTap,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouch,
                      minHeight: AppSizes.minTouch,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    tooltip: 'Hapus jadwal jam ${item.time}',
                    onPressed: onDelete,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouch,
                      minHeight: AppSizes.minTouch,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
