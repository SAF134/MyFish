import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import '../data/auth_repository.dart';
import '../data/device_repository.dart';
import '../data/models/device_models.dart';

/// Header atas tetap (fixed header) untuk halaman Beranda, Jadwal, Riwayat,
/// dan Pengaturan. Posisi tidak bergerak saat pengguna menggulir layar.
///
/// Menampilkan logo MyFish + teks "MyFish" di pojok kiri, serta status koneksi
/// ESP32 dengan desain titik point + Terhubung/Terputus di pojok kanan.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.isOnline,
    this.authRepository,
    this.deviceRepository,
  });

  /// Status koneksi ESP32. Jika null, akan membaca otomatis dari stream Firestore.
  final bool? isOnline;
  final AuthRepository? authRepository;
  final DeviceRepository? deviceRepository;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: Row(
                children: [
                  // Logo + Teks MyFish
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/myfish.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.set_meal_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Semantics(
                        header: true,
                        child: Text(
                          'MyFish',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Status ESP32: Titik Tombol Point + Terhubung/Terputus
                  if (isOnline != null)
                    _buildStatusPill(textTheme, isOnline!)
                  else
                    _buildStreamedStatus(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamedStatus(TextTheme textTheme) {
    final auth = authRepository ?? AuthRepository();
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return _buildStatusPill(textTheme, false);
    }

    final devRepo = deviceRepository ?? DeviceRepository();
    return StreamBuilder<DeviceData?>(
      stream: devRepo.watchDevice(uid),
      builder: (context, snapshot) {
        final online = snapshot.data?.isOnline() ?? false;
        return _buildStatusPill(textTheme, online);
      },
    );
  }

  Widget _buildStatusPill(TextTheme textTheme, bool online) {
    final statusText = online ? 'Terhubung' : 'Terputus';
    final dotColor = online ? AppColors.success : AppColors.error;
    final bgColor = online ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final borderColor = online ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A);
    final textColor = online ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Semantics(
      label: 'Status ESP32: $statusText',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titik tombol point
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.45),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
