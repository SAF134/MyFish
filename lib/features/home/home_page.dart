import 'package:flutter/material.dart';

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
import 'widgets/device_status_card.dart';
import 'widgets/feeding_chart.dart';
import 'widgets/manual_feed_sheet.dart';
import 'widgets/recent_history_section.dart';
import 'widgets/today_schedules_section.dart';

/// Halaman Beranda aplikasi MyFish (DESIGN.md §6).
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
    this.onViewAllSchedules,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;
  final VoidCallback? onViewAllSchedules;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? _deviceName;

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
    final uid = _effectiveUid;
    if (uid != null) {
      _deviceRepository.cleanCompletedCommands(uid);
      _deviceRepository.trimHistory(uid);
    }
  }

  Future<void> _loadDeviceName() async {
    final uid = _effectiveUid;
    if (uid == null) return;
    final item = await _deviceRepository.getDeviceDirectoryItem(uid);
    if (mounted && item != null) {
      setState(() => _deviceName = item.name);
    }
  }

  Future<void> _openManualFeed(String uid) async {
    final level = await ManualFeedSheet.show(
      context,
      uid: uid,
      deviceRepository: _deviceRepository,
    );

    if (level != null && mounted) {
      AppSnackbar.success(context, 'Pakan level $level berhasil');
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
              icon: Icons.account_circle_outlined,
              title: 'Belum Terhubung',
              message:
                  'Silakan masuk ke akun alat Anda untuk memantau pakan ikan.',
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
                if (deviceSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screen),
                      child: ErrorView(
                        title: 'Gagal memuat status alat',
                        message: 'Periksa koneksi internet Anda.',
                        onRetry: () => setState(() {}),
                      ),
                    ),
                  );
                }

                final device = deviceSnapshot.data;
                final isOnline = device?.isOnline() ?? false;
                final name =
                    _deviceName ??
                    _authRepository.currentUser?.email ??
                    'MyFish ESP32';

                return StreamBuilder<List<ScheduleItem>>(
                  stream: _deviceRepository.watchSchedules(uid),
                  builder: (context, schedulesSnapshot) {
                    final schedules = schedulesSnapshot.data ?? [];

                    return StreamBuilder<List<HistoryItem>>(
                      stream: _deviceRepository.watchHistory(uid),
                      builder: (context, historySnapshot) {
                        final history = historySnapshot.data ?? [];
                        final isLoading =
                            deviceSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !deviceSnapshot.hasData;

                        if (isLoading) {
                          return _buildLoadingSkeleton();
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isTwoColumn = constraints.maxWidth >= 520;

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screen,
                                AppSpacing.lg,
                                AppSpacing.screen,
                                100, // Space untuk bottom nav pill
                              ),
                              children: [
                                if (isTwoColumn) ...[
                                  // Tata letak 2 kolom untuk tablet/layar lebar (DESIGN.md §9)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Kolom Kiri: Status Alat + Jadwal
                                      Expanded(
                                        child: Column(
                                          children: [
                                            DeviceStatusCard(
                                              device: device,
                                              deviceName: name,
                                              onRefresh: () async =>
                                                  setState(() {}),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xl,
                                            ),
                                            TodaySchedulesSection(
                                              schedules: schedules,
                                              onViewAll:
                                                  widget.onViewAllSchedules ??
                                                  () {},
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xl,
                                            ),
                                            RecentHistorySection(
                                              history: history,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),

                                      // Kolom Kanan: Grafik 7 Hari + Pakan Manual
                                      Expanded(
                                        child: Column(
                                          children: [
                                            FeedingChart(history: history),
                                            const SizedBox(
                                              height: AppSpacing.xl,
                                            ),
                                            AppButton.primary(
                                              label: isOnline
                                                  ? 'Beri Pakan Manual'
                                                  : 'Beri Pakan Manual (Alat Offline)',
                                              icon: Icons.fastfood_rounded,
                                              onPressed: isOnline
                                                  ? () => _openManualFeed(uid)
                                                  : null,
                                            ),
                                            if (!isOnline) ...[
                                              const SizedBox(
                                                height: AppSpacing.xs,
                                              ),
                                              Text(
                                                'Pakan manual dinonaktifkan saat alat offline.',
                                                textAlign: TextAlign.center,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Tata letak 1 kolom untuk ponsel
                                  // 2. Kartu Status Alat
                                  DeviceStatusCard(
                                    device: device,
                                    deviceName: name,
                                    onRefresh: () async => setState(() {}),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // 3. Jadwal Hari Ini
                                  TodaySchedulesSection(
                                    schedules: schedules,
                                    onViewAll:
                                        widget.onViewAllSchedules ?? () {},
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  // 4. Riwayat Pakan Terakhir
                                  RecentHistorySection(history: history),
                                  const SizedBox(height: AppSpacing.xl),

                                  // 5. Grafik Pakan 7 Hari
                                  FeedingChart(history: history),
                                  const SizedBox(height: AppSpacing.xxl),

                                  // 6. Tombol Primer: Beri Pakan Manual (lebar penuh)
                                  AppButton.primary(
                                    label: isOnline
                                        ? 'Beri Pakan Manual'
                                        : 'Beri Pakan Manual (Alat Offline)',
                                    icon: Icons.fastfood_rounded,
                                    onPressed: isOnline
                                        ? () => _openManualFeed(uid)
                                        : null,
                                  ),
                                  if (!isOnline) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Center(
                                      child: Text(
                                        'Pakan manual dinonaktifkan saat alat offline.',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            );
                          },
                        );
                      },
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

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: const [
        Skeleton.card(height: 140),
        SizedBox(height: AppSpacing.xl),
        Skeleton.card(height: 100),
        SizedBox(height: AppSpacing.xl),
        Skeleton.card(height: 200),
      ],
    );
  }
}
