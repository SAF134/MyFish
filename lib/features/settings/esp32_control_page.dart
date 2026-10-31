import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/auth_repository.dart';
import '../../data/device_repository.dart';
import '../../data/models/device_models.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/password_dialog.dart';
import '../../widgets/slide_confirm.dart';
import '../../widgets/state_views.dart';
import 'widgets/confirm_action_sheet.dart';

/// Halaman Kontrol ESP32 (Reset & Matikan) - DESIGN.md §6 & §7a.
class Esp32ControlPage extends StatefulWidget {
  const Esp32ControlPage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;

  @override
  State<Esp32ControlPage> createState() => _Esp32ControlPageState();
}

class _Esp32ControlPageState extends State<Esp32ControlPage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;

  Future<void> _handleReset(String uid) async {
    // 1. Dialog password re-autentikasi
    final verified = await showPasswordDialog(
      context,
      verify: (pwd) => _authRepository.reauthenticate(pwd),
      title: 'Konfirmasi Reset ESP32',
      message: 'Masukkan password akun untuk mereset perangkat alat.',
      confirmLabel: 'Lanjut',
    );

    if (!verified || !mounted) return;

    // 2. SlideConfirm modal sheet
    final confirmed = await ConfirmActionSheet.show(
      context,
      title: 'Reset Ulang ESP32',
      message: 'Mikrokontroler ESP32 akan dimulai ulang dari awal. Pastikan tidak ada proses pakan yang sedang berjalan.',
      slideLabel: 'Geser untuk reset ESP32',
      variant: SlideConfirmVariant.danger,
      onConfirm: () async {
        await _deviceRepository.sendResetCommand(uid);
      },
    );

    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Perintah reset terkirim');
    }
  }

  Future<void> _handleShutdown(String uid) async {
    // 1. Dialog password re-autentikasi
    final verified = await showPasswordDialog(
      context,
      verify: (pwd) => _authRepository.reauthenticate(pwd),
      title: 'Konfirmasi Matikan ESP32',
      message: 'Masukkan password akun untuk mematikan perangkat alat ke mode deep sleep.',
      confirmLabel: 'Lanjut',
    );

    if (!verified || !mounted) return;

    // 2. SlideConfirm modal sheet
    final confirmed = await ConfirmActionSheet.show(
      context,
      title: 'Matikan ESP32 (Deep Sleep)',
      message: 'Alat akan masuk mode tidur hemat daya. Untuk menyalakan kembali, tombol fisik pada mikrokontroler perlu ditekan.',
      slideLabel: 'Geser untuk matikan ESP32',
      variant: SlideConfirmVariant.danger,
      onConfirm: () async {
        await _deviceRepository.sendShutdownCommand(uid);
      },
    );

    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Perintah matikan terkirim');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = _effectiveUid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.screen),
            child: Center(child: AppCircleIconButton.back()),
          ),
          title: const Text('Kontrol ESP32'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: EmptyView(
              icon: Icons.power_settings_new_rounded,
              title: 'Belum Terhubung',
              message: 'Masuk ke akun alat untuk mengakses kontrol ESP32.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.screen),
          child: Center(
            child: AppCircleIconButton.back(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Kontrol ESP32'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: StreamBuilder<DeviceData?>(
              stream: _deviceRepository.watchDevice(uid),
              builder: (context, snapshot) {
                final isOnline = snapshot.data?.isOnline() ?? false;

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [
                    // Kartu Peringatan Singkat
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aksi Sensitif Perangkat',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Aksi di bawah ini memerlukan re-autentikasi password dan konfirmasi tombol geser demi keamanan alat Anda.',
                                  textAlign: TextAlign.justify,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Banner Jika Offline
                    if (!isOnline) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.offline.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.input),
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
                                'Alat sedang offline. Aksi kontrol ESP32 dinonaktifkan.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Kartu Aksi 1: Reset Ulang ESP32
                    AppCard(
                      enabled: isOnline,
                      onTap: isOnline ? () => _handleReset(uid) : null,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      semanticLabel:
                          'Reset Ulang ESP32. ${isOnline ? "" : "Dinonaktifkan karena alat offline."}',
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.primaryTint
                                  : AppColors.surfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restart_alt_rounded,
                              color: isOnline
                                  ? AppColors.primary
                                  : AppColors.offline,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Ulang ESP32',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isOnline
                                        ? AppColors.text
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Memulai ulang sistem mikrokontroler dari jauh.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isOnline
                                ? AppColors.textMuted
                                : AppColors.border,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Kartu Aksi 2: Matikan ESP32
                    AppCard(
                      enabled: isOnline,
                      onTap: isOnline ? () => _handleShutdown(uid) : null,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      semanticLabel:
                          'Matikan ESP32. ${isOnline ? "" : "Dinonaktifkan karena alat offline."}',
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.error.withValues(alpha: 0.12)
                                  : AppColors.surfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.power_settings_new_rounded,
                              color: isOnline
                                  ? AppColors.error
                                  : AppColors.offline,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Matikan ESP32',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isOnline
                                        ? AppColors.error
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Memasukkan alat ke mode deep sleep hemat daya.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isOnline
                                ? AppColors.textMuted
                                : AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
