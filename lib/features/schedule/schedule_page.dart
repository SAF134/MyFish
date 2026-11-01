import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/auth_repository.dart';
import '../../data/device_repository.dart';
import '../../data/models/device_models.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';
import 'widgets/delete_schedule_dialog.dart';
import 'widgets/schedule_card.dart';
import 'widgets/schedule_form_sheet.dart';
import 'widgets/toggle_schedule_dialog.dart';

/// Halaman kelola Jadwal Pakan (DESIGN.md §6).
class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;

  Future<void> _openAddSchedule(
    BuildContext context,
    String uid,
    List<ScheduleItem> existing,
  ) async {
    if (existing.length >= AppConstants.maxScheduleCount) {
      AppSnackbar.error(
        context,
        'Batas maksimal ${AppConstants.maxScheduleCount} jadwal telah tercapai. Hapus salah satu jadwal jika ingin menambah baru.',
      );
      return;
    }

    await ScheduleFormSheet.show(
      context,
      existingSchedules: existing,
      onSave: (time, level) async {
        await _deviceRepository.addSchedule(uid, time: time, level: level);
        if (context.mounted) {
          AppSnackbar.success(context, 'Jadwal disimpan');
        }
      },
    );
  }

  Future<void> _openEditSchedule(
    BuildContext context,
    String uid,
    ScheduleItem item,
    List<ScheduleItem> existing,
  ) async {
    await ScheduleFormSheet.show(
      context,
      initialItem: item,
      existingSchedules: existing,
      onSave: (time, level) async {
        await _deviceRepository.updateSchedule(
          uid,
          id: item.id,
          time: time,
          level: level,
          enabled: item.enabled,
        );
        if (context.mounted) {
          AppSnackbar.success(context, 'Jadwal diperbarui');
        }
      },
    );
  }

  Future<void> _handleToggleSchedule(
    BuildContext context,
    String uid,
    ScheduleItem item,
    bool enabled,
  ) async {
    final confirmed = await showToggleScheduleDialog(
      context,
      time: item.time,
      enabled: enabled,
    );

    if (confirmed) {
      await _deviceRepository.toggleSchedule(uid, id: item.id, enabled: enabled);
      if (context.mounted) {
        AppSnackbar.success(
          context,
          enabled ? 'Jadwal diaktifkan' : 'Jadwal dinonaktifkan',
        );
      }
    }
  }

  Future<void> _confirmDeleteSchedule(
    BuildContext context,
    String uid,
    ScheduleItem item,
  ) async {
    final confirmed = await showDeleteScheduleDialog(context, time: item.time);

    if (confirmed) {
      await _deviceRepository.deleteSchedule(uid, item.id);
      if (context.mounted) {
        AppSnackbar.success(context, 'Jadwal dihapus');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = _effectiveUid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: EmptyView(
              icon: Icons.schedule_rounded,
              title: 'Belum Terhubung',
              message: 'Silakan masuk ke akun alat Anda untuk mengatur jadwal pakan.',
              actionLabel: 'Masuk',
              onAction: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        authRepository: _authRepository,
        deviceRepository: _deviceRepository,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: StreamBuilder<DeviceData?>(
              stream: _deviceRepository.watchDevice(uid),
              builder: (context, deviceSnapshot) {
                final isOffline =
                    deviceSnapshot.hasData &&
                    !(deviceSnapshot.data?.isOnline() ?? false);

                return StreamBuilder<List<ScheduleItem>>(
                  stream: _deviceRepository.watchSchedules(uid),
                  builder: (context, schedulesSnapshot) {
                    if (schedulesSnapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.screen),
                          child: ErrorView(
                            title: 'Gagal memuat jadwal',
                            message: 'Periksa koneksi internet Anda.',
                            onRetry: () => setState(() {}),
                          ),
                        ),
                      );
                    }

                    final isLoading =
                        schedulesSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !schedulesSnapshot.hasData;

                    if (isLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.screen),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Jadwal', style: textTheme.titleLarge),
                                const Skeleton(width: 90, height: 36),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const SkeletonList(itemCount: 4, itemHeight: 80),
                          ],
                        ),
                      );
                    }

                    final schedules = schedulesSnapshot.data ?? [];
                    final isMaxSchedules =
                        schedules.length >= AppConstants.maxScheduleCount;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.lg,
                        AppSpacing.screen,
                        100, // Space untuk bottom nav
                      ),
                      children: [
                        // Header Judul
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Jadwal Pakan Harian',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
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
                                color: isMaxSchedules
                                    ? AppColors.error.withValues(alpha: 0.12)
                                    : AppColors.primaryTint,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.chip),
                                border: Border.all(
                                  color: isMaxSchedules
                                      ? AppColors.error.withValues(alpha: 0.3)
                                      : AppColors.primaryLight
                                          .withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                '${schedules.length}/${AppConstants.maxScheduleCount} Jadwal',
                                style: textTheme.labelSmall?.copyWith(
                                  color: isMaxSchedules
                                      ? AppColors.error
                                      : AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Banner Offline (DESIGN.md §8)
                        if (isOffline) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.offline.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppRadius.input,
                              ),
                              border: Border.all(
                                color: AppColors.offline.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  color: AppColors.offline,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Alat offline. Perubahan akan tersinkron saat online.',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Daftar Jadwal atau State Kosong
                        if (schedules.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xl),
                            child: EmptyView(
                              icon: Icons.alarm_rounded,
                              title: 'Belum ada jadwal',
                              message:
                                  'Buat jadwal pakan harian agar ikan Anda mendapatkan pakan tepat waktu secara otomatis.',
                            ),
                          )
                        else
                          for (var i = 0; i < schedules.length; i++) ...[
                            if (i > 0)
                              const SizedBox(height: AppSpacing.cardGap),
                            ScheduleCard(
                              item: schedules[i],
                              onTap: () => _openEditSchedule(
                                context,
                                uid,
                                schedules[i],
                                schedules,
                              ),
                              onToggle: (val) => _handleToggleSchedule(
                                context,
                                uid,
                                schedules[i],
                                val,
                              ),
                              onDelete: () => _confirmDeleteSchedule(
                                context,
                                uid,
                                schedules[i],
                              ),
                            ),
                          ],
                        const SizedBox(height: AppSpacing.lg),
                        if (isMaxSchedules) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Maksimal 10 jadwal telah tercapai. Hapus salah satu jadwal jika ingin menambah baru.',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        // Tombol Tambah Jadwal tunggal di bawah daftar jadwal
                        AppButton.primary(
                          label: isMaxSchedules
                              ? 'Batas 10 Jadwal Tercapai'
                              : 'Tambah Jadwal',
                          icon: isMaxSchedules
                              ? Icons.lock_outline_rounded
                              : Icons.add_rounded,
                          onPressed: isMaxSchedules
                              ? null
                              : () =>
                                  _openAddSchedule(context, uid, schedules),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
