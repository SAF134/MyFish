import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/auth_repository.dart';
import '../../data/device_repository.dart';
import '../../data/models/device_models.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';
import 'widgets/delete_history_sheet.dart';
import 'widgets/history_card.dart';

/// Halaman Riwayat Pemberian Pakan (DESIGN.md §6).
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;

  Map<DateTime, List<HistoryItem>> _groupByDate(List<HistoryItem> items) {
    final map = <DateTime, List<HistoryItem>>{};
    for (final item in items) {
      final key = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  Future<void> _handleDelete(
    BuildContext context,
    String uid,
    HistoryItem item,
  ) async {
    await DeleteHistorySheet.show(
      context,
      item: item,
      onDelete: () async {
        await _deviceRepository.deleteHistoryItem(uid, item.id);
        if (context.mounted) {
          AppSnackbar.success(context, 'Riwayat dihapus');
        }
      },
    );
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
              icon: Icons.history_rounded,
              title: 'Belum Terhubung',
              message: 'Silakan masuk ke akun alat Anda untuk melihat riwayat pakan.',
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
      appBar: const AppHeader(),
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
                final isOnline = deviceSnapshot.data?.isOnline() ?? false;
                final isOffline = deviceSnapshot.hasData && !isOnline;

                return StreamBuilder<List<HistoryItem>>(
                  stream: _deviceRepository.watchHistory(uid),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.screen),
                          child: ErrorView(
                            title: 'Gagal memuat riwayat',
                            message: 'Periksa koneksi internet Anda.',
                            onRetry: () => setState(() {}),
                          ),
                        ),
                      );
                    }

                    final isLoading =
                        historySnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !historySnapshot.hasData;

                    if (isLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.screen),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Riwayat', style: textTheme.titleLarge),
                            const SizedBox(height: AppSpacing.xl),
                            const SkeletonList(itemCount: 5, itemHeight: 72),
                          ],
                        ),
                      );
                    }

                    final items = historySnapshot.data ?? [];
                    final grouped = _groupByDate(items);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.lg,
                        AppSpacing.screen,
                        100, // Space untuk bottom nav pill
                      ),
                      children: [
                        // Judul Layar
                        Semantics(
                          header: true,
                          child: Text(
                            'Riwayat Pakan',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Catatan kecil Firestore TTL 30 hari (DESIGN.md §6 & PRD)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(
                              AppRadius.input,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Riwayat otomatis terhapus setelah 30 hari',
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
                                    'Alat offline. Menampilkan data tersimpan. Hapus dinonaktifkan.',
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

                        // Daftar Riwayat atau State Kosong
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xxl),
                            child: EmptyView(
                              icon: Icons.history_rounded,
                              title: 'Belum ada riwayat pakan',
                              message: 'Catatan pemberian pakan otomatis dan manual akan muncul di sini setelah alat beroperasi.',
                            ),
                          )
                        else
                          for (final entry in grouped.entries) ...[
                            // Header Kelompok Tanggal
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                AppSpacing.md,
                                0,
                                AppSpacing.sm,
                              ),
                              child: Text(
                                DateFormatter.formatGroupDate(entry.key),
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Kartu Riwayat dalam Kelompok
                            for (var i = 0; i < entry.value.length; i++) ...[
                              if (i > 0) const SizedBox(height: AppSpacing.sm),
                              HistoryCard(
                                item: entry.value[i],
                                canDelete: isOnline,
                                onDelete: () =>
                                    _handleDelete(context, uid, entry.value[i]),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                          ],
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
