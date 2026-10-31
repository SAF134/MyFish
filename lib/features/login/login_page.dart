import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/auth_repository.dart';
import '../../data/device_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/password_field.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';

/// Halaman Masuk profesional: Memilih akun alat ESP32 dari `device_directory`
/// dan login terautentikasi melalui Firebase Auth.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authRepository, this.deviceRepository});

  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final DeviceRepository _deviceRepository =
      widget.deviceRepository ?? DeviceRepository();

  final TextEditingController _passwordController = TextEditingController();

  List<DeviceDirectoryItem> _devices = [];
  DeviceDirectoryItem? _selectedDevice;

  bool _isLoadingDevices = true;
  String? _devicesError;

  bool _isSubmitting = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoadingDevices = true;
      _devicesError = null;
    });

    try {
      final list = await _deviceRepository.getDeviceDirectory();
      if (!mounted) return;
      setState(() {
        _devices = list;
        _isLoadingDevices = false;
        if (list.isNotEmpty && _selectedDevice == null) {
          _selectedDevice = list.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingDevices = false;
        _devicesError =
            'Tidak dapat memuat daftar akun. Periksa internet Anda.';
      });
    }
  }

  Future<void> _submitLogin() async {
    final device = _selectedDevice;
    if (device == null) {
      setState(() => _authError = 'Pilih akun alat terlebih dahulu');
      return;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _authError = 'Password wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _authError = null;
    });

    final error = await _authRepository.signIn(
      email: device.email,
      password: password,
    );

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.shell, (route) => false);
    } else {
      setState(() {
        _isSubmitting = false;
        _authError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Masuk Akun Alat'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Muat ulang daftar alat',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoadingDevices ? null : _loadDevices,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.md,
              ),
              children: [
                // 1. Hero Branding Banner Profesional
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      // Logo Badge dengan Frame Elegan
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140284C7),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Image.asset(
                          'assets/images/myfish.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.set_meal_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Identitas & Badge Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'MyFish',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: AppRadius.pillAll,
                                    border: Border.all(
                                      color: AppColors.primaryLight
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ESP32 IoT',
                                        style: textTheme.labelSmall?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Monitoring & kontrol pakan ikan cerdas berbasis mikrokontroler ESP32 & Firebase.',
                              textAlign: TextAlign.justify,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
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

                // 2. Judul Bagian: Pilih Akun Alat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Pilih Akun Alat',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (!_isLoadingDevices && _devices.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.pillAll,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${_devices.length} Alat Terdaftar',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pilih akun perangkat ESP32 Anda di bawah ini dan masukkan password untuk memantau pakan secara real-time.',
                  textAlign: TextAlign.justify,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Area daftar akun alat
                _buildDeviceSection(),

                // Area input password & tombol Masuk
                if (_devices.isNotEmpty && !_isLoadingDevices) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Password Akun',
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PasswordField(
                    controller: _passwordController,
                    enabled: !_isSubmitting,
                    errorText: _authError,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitLogin(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton.primary(
                    label: 'Masuk',
                    icon: Icons.login_rounded,
                    isLoading: _isSubmitting,
                    loadingLabel: 'Memverifikasi akun…',
                    onPressed: _selectedDevice != null ? _submitLogin : null,
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // 3. Banner Keamanan Ringkas
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.inputAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Autentikasi terenkripsi aman Firebase',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 4. Link Kebijakan Privasi
                Center(
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.privacy_tip_outlined,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    label: Text(
                      'Kebijakan Privasi',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
                    },
                  ),
                ),

                // Footer
                Center(
                  child: Text(
                    'MyFish v1.0 • IoT Smart Feeder',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceSection() {
    if (_isLoadingDevices) {
      return const Column(
        children: [
          Skeleton.card(height: 68),
          SizedBox(height: AppSpacing.cardGap),
          Skeleton.card(height: 68),
        ],
      );
    }

    if (_devicesError != null) {
      return ErrorView(
        title: 'Gagal memuat akun',
        message: _devicesError,
        onRetry: _loadDevices,
      );
    }

    if (_devices.isEmpty) {
      return const EmptyView(
        icon: Icons.devices_other_rounded,
        title: 'Belum ada akun alat',
        message:
            'Tidak ada perangkat terdaftar pada sistem. Hubungi pengembang untuk mendaftarkan alat Anda.',
      );
    }

    return Column(
      children: [
        for (final item in _devices) ...[
          _DeviceAccountCard(
            item: item,
            isSelected: _selectedDevice?.id == item.id,
            onTap: _isSubmitting
                ? null
                : () {
                    setState(() {
                      _selectedDevice = item;
                      _authError = null;
                    });
                  },
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }
}

/// Kartu pilihan akun alat profesional dengan radio visual, ikon IoT,
/// dan feedback interaktif sesuai standar DESIGN.md.
class _DeviceAccountCard extends StatelessWidget {
  const _DeviceAccountCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final DeviceDirectoryItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      selected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      semanticLabel: '${item.name}, ${item.email}',
      child: Row(
        children: [
          // Avatar modul perangkat
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x331976D2),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.memory_rounded,
              color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Detail informasi akun & alat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryTint
                            : AppColors.surfaceAlt,
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight.withValues(alpha: 0.5)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        'ESP32',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Indikator pemilihan akun (Radio / Checkmark Visual)
          AnimatedContainer(
            duration: AppDurations.fast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.onPrimary,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
