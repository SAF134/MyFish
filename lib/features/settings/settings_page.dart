import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/auth_repository.dart';
import '../../data/device_repository.dart';
import '../../data/models/device_models.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/status_badge.dart';

/// Tab Pengaturan (DESIGN.md §6 & §7).
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
    this.email,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;
  final String? email;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _cooldownKey = 'myfish_last_update_check';

  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;
  String? get _effectiveEmail =>
      widget.email ?? _authRepository.currentUser?.email;

  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _initCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckMillis = prefs.getInt(_cooldownKey);
      if (lastCheckMillis != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMillis);
        final elapsed = DateTime.now().difference(lastCheck).inSeconds;
        if (elapsed < 60) {
          setState(() {
            _cooldownSeconds = 60 - elapsed;
          });
          _startCooldownTimer();
        }
      }
    } catch (_) {}
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _checkUpdate() async {
    setState(() => _isCheckingUpdate = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cooldownKey, DateTime.now().millisecondsSinceEpoch);
      setState(() => _cooldownSeconds = 60);
      _startCooldownTimer();

      final config = await _deviceRepository.checkAppVersion();
      if (!mounted) return;

      if (config == null) {
        AppSnackbar.error(context, 'Tidak dapat memeriksa pembaruan');
        return;
      }

      final hasUpdate = AppVersionConfig.isNewer(
        AppConstants.appVersion,
        config.latest,
      );

      if (hasUpdate) {
        _showUpdateDialog(config);
      } else {
        AppSnackbar.info(context, 'Sudah versi terbaru');
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Tidak dapat memeriksa pembaruan');
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  void _showUpdateDialog(AppVersionConfig config) {
    final textTheme = Theme.of(context).textTheme;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(
          Icons.system_update_rounded,
          color: AppColors.primary,
          size: 32,
        ),
        title: const Text('Pembaruan Tersedia!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi ${config.latest} telah tersedia (versi Anda saat ini: v${AppConstants.appVersion}).',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unduh pembaruan sekarang untuk mendapatkan fitur terbaru dan stabilitas sistem terbaik.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Nanti saja'),
          ),
          AppButton.primary(
            label: 'Perbarui',
            expanded: false,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final uri = Uri.parse(config.downloadUrl);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _authRepository.signOut();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  Future<void> _showLogoutConfirmDialog() async {
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.error,
          size: 32,
        ),
        title: const Text('Keluar dari Akun?'),
        content: Text(
          'Anda akan keluar dari akun alat ini dan perlu memasukkan password kembali untuk mengakses dashboard.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.danger(
                  label: 'Keluar',
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton.secondary(
                  label: 'Batal',
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uid = _effectiveUid;
    final email = _effectiveEmail;

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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                140, // Ruang ekstra agar SlideConfirm bebas dari tombol navbar bawah
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Pengaturan',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
          // Kartu Profil Alat & Status Realtime
          if (uid != null)
            StreamBuilder<DeviceData?>(
              stream: _deviceRepository.watchDevice(uid),
              builder: (context, snapshot) {
                final device = snapshot.data;
                final isOnline = device?.isOnline() ?? false;
                final lastSeen = device?.lastSeen;

                String subtext;
                if (isOnline) {
                  subtext = device?.fwVersion != null
                      ? 'ESP32 MyFish v${device!.fwVersion}'
                      : 'ESP32 MyFish Terhubung';
                } else if (lastSeen != null) {
                  subtext =
                      'Terakhir terhubung: ${DateFormatter.formatDateTime(lastSeen)}';
                } else {
                  subtext = 'Alat belum pernah terhubung';
                }

                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_circle_rounded,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email ?? 'Akun Alat',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtext,
                              style: textTheme.bodySmall?.copyWith(
                                color: isOnline
                                    ? AppColors.textMuted
                                    : AppColors.offline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge(
                        status: isOnline
                            ? DeviceStatus.online
                            : DeviceStatus.offline,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Belum masuk akun alat',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),

          // Grup 1: Kontrol Alat (DESIGN.md §6 & §7)
          Text(
            'KONTROL ALAT',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.power_settings_new_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Kontrol ESP32'),
                  subtitle: const Text('Reset ulang atau matikan perangkat'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.esp32Control);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Kalibrasi Takaran'),
                  subtitle: const Text('Atur durasi bukaan servo level 1–5'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.calibration);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Grup 2: Informasi & Dukungan (DESIGN.md §6 & §7c-7f)
          Text(
            'INFORMASI & LAINNYA',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Tentang Aplikasi'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.aboutApp);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Tentang Pengembang'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.aboutDeveloper);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.volunteer_activism_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Dukung Pengembang'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.supportDeveloper);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Kebijakan Privasi'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Versi & Tombol Periksa Pembaruan (DESIGN.md §6 & §7)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Versi ${AppConstants.appVersion}',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        'Rilis',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  label: _cooldownSeconds > 0
                      ? 'Periksa Pembaruan (${_cooldownSeconds}s)'
                      : 'Periksa Pembaruan',
                  icon: Icons.refresh_rounded,
                  isLoading: _isCheckingUpdate,
                  loadingLabel: 'Memeriksa pembaruan…',
                  onPressed: _cooldownSeconds > 0 || _isCheckingUpdate
                      ? null
                      : _checkUpdate,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Tombol Keluar Akun
          AppButton.danger(
            label: 'Keluar Akun',
            icon: Icons.logout_rounded,
            onPressed: _showLogoutConfirmDialog,
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
