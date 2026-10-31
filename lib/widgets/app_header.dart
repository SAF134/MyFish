import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Header atas tetap (fixed header) untuk halaman Beranda, Jadwal, Riwayat,
/// dan Pengaturan. Posisi tidak bergerak saat pengguna menggulir layar.
///
/// Menampilkan logo MyFish + teks "MyFish" di pojok kiri, serta kluster
/// dekoratif ikon ikan, air, dan akuarium di kanan untuk mengisi ruang kosong.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

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

                  // Kluster Ikon: Ikan, Air, dan Akuarium
                  Semantics(
                    label: 'Indikator ekosistem: Ikan, Air, dan Akuarium',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Ikon Ikan
                          _HeaderDecorativeIcon(
                            icon: Icons.set_meal_rounded,
                            tooltip: 'Pakan & Kesehatan Ikan',
                            backgroundColor: AppColors.primaryTint,
                            iconColor: AppColors.primaryDark,
                          ),
                          const SizedBox(width: AppSpacing.xs),

                          // 2. Ikon Air
                          const _HeaderDecorativeIcon(
                            icon: Icons.water_drop_rounded,
                            tooltip: 'Kualitas & Kebersihan Air',
                            backgroundColor: Color(0xFFE0F7FA),
                            iconColor: Color(0xFF00838F),
                          ),
                          const SizedBox(width: AppSpacing.xs),

                          // 3. Ikon Akuarium / Gelombang
                          const _HeaderDecorativeIcon(
                            icon: Icons.waves_rounded,
                            tooltip: 'Ekosistem Akuarium Pintar',
                            backgroundColor: Color(0xFFEDE7F6),
                            iconColor: Color(0xFF5E35B1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderDecorativeIcon extends StatefulWidget {
  const _HeaderDecorativeIcon({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;

  @override
  State<_HeaderDecorativeIcon> createState() => _HeaderDecorativeIconState();
}

class _HeaderDecorativeIconState extends State<_HeaderDecorativeIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.82 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
