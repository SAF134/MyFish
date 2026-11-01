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

/// Halaman Kontrol ESP32 (Reset, Matikan Deep Sleep & Nyalakan Kembali) - DESIGN.md §6 & §7a.
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

  @override
  void initState() {
    super.initState();
    final uid = _effectiveUid;
    if (uid != null) {
      _deviceRepository.cleanCompletedCommands(uid);
    }
  }

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
      message:
          'Mikrokontroler ESP32 akan dimulai ulang dari awal. Pastikan tidak ada proses pakan yang sedang berjalan.',
      slideLabel: 'Geser untuk reset ESP32',
      variant: SlideConfirmVariant.danger,
      onConfirm: () async {
        await _deviceRepository.sendResetCommand(uid);
        _deviceRepository.cleanCompletedCommands(uid);
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
      message:
          'Masukkan password akun untuk mematikan perangkat alat ke mode deep sleep.',
      confirmLabel: 'Lanjut',
    );

    if (!verified || !mounted) return;

    // 2. SlideConfirm modal sheet
    final confirmed = await ConfirmActionSheet.show(
      context,
      title: 'Matikan ESP32 (Deep Sleep)',
      message:
          'Alat akan masuk mode tidur hemat daya mendalam. Anda dapat menyalakannya kembali melalui aplikasi dengan konfirmasi password atau menekan tombol fisik.',
      slideLabel: 'Geser untuk matikan ESP32',
      variant: SlideConfirmVariant.danger,
      onConfirm: () async {
        await _deviceRepository.sendShutdownCommand(uid);
        _deviceRepository.cleanCompletedCommands(uid);
      },
    );

    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Perintah matikan terkirim');
    }
  }

  Future<void> _handleWakeup(String uid) async {
    // 1. Dialog password re-autentikasi
    final verified = await showPasswordDialog(
      context,
      verify: (pwd) => _authRepository.reauthenticate(pwd),
      title: 'Konfirmasi Nyalakan ESP32',
      message:
          'Masukkan password akun untuk menyalakan kembali perangkat alat dari mode deep sleep.',
      confirmLabel: 'Lanjut',
    );

    if (!verified || !mounted) return;

    // 2. SlideConfirm modal sheet
    final confirmed = await ConfirmActionSheet.show(
      context,
      title: 'Nyalakan Kembali ESP32',
      message:
          'Sistem mikrokontroler akan diaktifkan kembali dari mode deep sleep. Sinyal status bangun akan dikirimkan ke cloud.',
      slideLabel: 'Geser untuk nyalakan ESP32',
      variant: SlideConfirmVariant.normal,
      onConfirm: () async {
        await _deviceRepository.sendWakeupCommand(uid);
        _deviceRepository.cleanCompletedCommands(uid);
      },
    );

    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Perintah menyalakan ESP32 terkirim');
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
                final device = snapshot.data;
                final isOnline = device?.isOnline() ?? false;
                final isDeepSleep = !isOnline || device?.status == 'off';

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

                    // Banner Jika Offline / Deep Sleep
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
                      const SizedBox(height: AppSpacing.md),

                      // Informasi Khusus Mode Deep Sleep
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFECB3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bedtime_rounded,
                                color: Color(0xFFF57F17),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ESP32 Sedang Dimatikan (Mode Deep Sleep)',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFBF360C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Perangkat mikrokontroler sedang dalam mode deep sleep hemat daya. Anda dapat menyalakan kembali perangkat lewat tombol di bawah dengan konfirmasi password akun, atau menekan tombol fisik EN/daya pada board ESP32.',
                                    textAlign: TextAlign.justify,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF5D4037),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Kartu Aksi: Nyalakan ESP32 (Aktif ketika alat sedang deep sleep / offline)
                    if (isDeepSleep) ...[
                      AppCard(
                        enabled: true,
                        onTap: () => _handleWakeup(uid),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        semanticLabel: 'Nyalakan ESP32 dari mode deep sleep',
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFA5D6A7),
                                ),
                              ),
                              child: const Icon(
                                Icons.power_settings_new_rounded,
                                color: AppColors.success,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nyalakan ESP32',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bangunkan alat dari mode deep sleep dan aktifkan kembali.',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
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
