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
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';
import 'widgets/confirm_action_sheet.dart';

/// Halaman Kalibrasi Takaran Pakan Level 1–5 (DESIGN.md §6 & §7b).
class CalibrationPage extends StatefulWidget {
  const CalibrationPage({
    super.key,
    this.authRepository,
    this.deviceRepository,
    this.uid,
  });

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;
  final String? uid;

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  String? get _effectiveUid => widget.uid ?? _authRepository.currentUser?.uid;

  List<double>? _initialValues;
  late List<double> _currentValues;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentValues = [1.0, 2.0, 3.0, 4.0, 5.0];
  }

  void _initFromDevice(DeviceData? device) {
    if (_initialValues != null) return;
    final calib = device?.calibration ?? {};
    final loaded = [
      calib['l1'] ?? 1.0,
      calib['l2'] ?? 2.0,
      calib['l3'] ?? 3.0,
      calib['l4'] ?? 4.0,
      calib['l5'] ?? 5.0,
    ];
    _initialValues = List.from(loaded);
    _currentValues = List.from(loaded);
  }

  double _round1(double val) => double.parse(val.toStringAsFixed(1));

  void _step(int index, double delta) {
    final next = _round1((_currentValues[index] + delta).clamp(0.1, 10.0));
    setState(() {
      _currentValues[index] = next;
    });
  }

  bool get _isStrictlyIncreasing {
    for (var i = 0; i < _currentValues.length - 1; i++) {
      if (_currentValues[i] >= _currentValues[i + 1]) {
        return false;
      }
    }
    return true;
  }

  bool get _hasChanges {
    if (_initialValues == null) return false;
    for (var i = 0; i < 5; i++) {
      if ((_currentValues[i] - _initialValues![i]).abs() > 0.01) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handleSave(String uid) async {
    // 1. Verifikasi Password Akun
    final verified = await showPasswordDialog(
      context,
      verify: (pwd) => _authRepository.reauthenticate(pwd),
      title: 'Konfirmasi Kalibrasi',
      message: 'Masukkan password akun untuk menyimpan perubahan durasi kalibrasi servo.',
      confirmLabel: 'Lanjut',
    );

    if (!verified || !mounted) return;

    // 2. SlideConfirm Modal Sheet
    final confirmed = await ConfirmActionSheet.show(
      context,
      title: 'Simpan Kalibrasi Takaran',
      message: 'Durasi pembukaan servo baru akan diperbarui ke mikrokontroler ESP32.',
      slideLabel: 'Geser untuk simpan kalibrasi',
      onConfirm: () async {
        setState(() => _isSaving = true);
        try {
          final calibMap = {
            'l1': _currentValues[0],
            'l2': _currentValues[1],
            'l3': _currentValues[2],
            'l4': _currentValues[3],
            'l5': _currentValues[4],
          };
          await _deviceRepository.updateCalibration(uid, calibMap);
          if (mounted) {
            setState(() {
              _initialValues = List.from(_currentValues);
            });
          }
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      },
    );

    if (confirmed == true && mounted) {
      AppSnackbar.success(context, 'Kalibrasi tersimpan');
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
          title: const Text('Kalibrasi Takaran'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: EmptyView(
              icon: Icons.tune_rounded,
              title: 'Belum Terhubung',
              message: 'Masuk ke akun alat untuk mengakses kalibrasi takaran.',
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
        title: const Text('Kalibrasi Takaran'),
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
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _initialValues == null) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.screen),
                    child: Column(
                      children: [
                        Skeleton(height: 50),
                        SizedBox(height: AppSpacing.lg),
                        SkeletonList(itemCount: 5, itemHeight: 64),
                      ],
                    ),
                  );
                }

                final isOnline = snapshot.data?.isOnline() ?? false;
                _initFromDevice(snapshot.data);

                final validOrder = _isStrictlyIncreasing;
                final canSave =
                    isOnline && _hasChanges && validOrder && !_isSaving;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.md,
                    AppSpacing.screen,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    // Deskripsi Pengantar
                    Text(
                      'Durasi Buka Servo per Level',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sesuaikan durasi bukaan servo (0,1 – 10,0 detik) untuk mengatur volume pakan yang keluar. Durasi wajib bertambah naik pada setiap level.',
                      textAlign: TextAlign.justify,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Banner Offline
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
                                'Alat sedang offline. Kalibrasi dinonaktifkan.',
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

                    // 5 Baris Stepper Level 1 - 5
                    for (var i = 0; i < 5; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _StepperRow(
                        level: i + 1,
                        seconds: _currentValues[i],
                        enabled: isOnline && !_isSaving,
                        onDecrement: _currentValues[i] > 0.1
                            ? () => _step(i, -0.1)
                            : null,
                        onIncrement: _currentValues[i] < 10.0
                            ? () => _step(i, 0.1)
                            : null,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),

                    // Pesan Validasi Jika Nilai Tidak Bertambah Naik
                    if (!validOrder) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Durasi takaran harus bertambah naik di setiap level (Level 1 < Level 2 < Level 3 < Level 4 < Level 5).',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Tombol Simpan Kalibrasi
                    AppButton.primary(
                      label: isOnline ? 'Simpan Kalibrasi' : 'Alat Offline',
                      isLoading: _isSaving,
                      loadingLabel: 'Menyimpan…',
                      onPressed: canSave ? () => _handleSave(uid) : null,
                    ),
                    if (isOnline && !_hasChanges && validOrder) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Center(
                        child: Text(
                          'Ubah nilai detik untuk mengaktifkan tombol Simpan.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
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

/// Baris stepper −/+ untuk satu level kalibrasi.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.level,
    required this.seconds,
    required this.enabled,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int level;
  final double seconds;
  final bool enabled;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Label Level
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              'Level $level',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),

          // Tombol Kurang (−)
          IconButton(
            onPressed: enabled ? onDecrement : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.primary,
            disabledColor: AppColors.border,
            tooltip: 'Kurangi 0,1 detik',
          ),

          // Tampilan Detik
          Container(
            width: 72,
            alignment: Alignment.center,
            child: Text(
              '${seconds.toStringAsFixed(1)} dtk',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: enabled ? AppColors.text : AppColors.textMuted,
              ),
            ),
          ),

          // Tombol Tambah (+)
          IconButton(
            onPressed: enabled ? onIncrement : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
            disabledColor: AppColors.border,
            tooltip: 'Tambah 0,1 detik',
          ),
        ],
      ),
    );
  }
}
