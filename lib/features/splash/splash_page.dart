import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/auth_repository.dart';

/// Layar Pembuka: Logo, nama, tagline, indikator loading melingkar.
/// Berpindah otomatis dalam waktu singkat ke Onboarding, Masuk, atau Beranda.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Tampil cukup waktu agar transisi halus (≤ 3 detik sesuai PRD).
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final user = _authRepository.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
      return;
    }

    final hasCompletedOnboarding = await _authRepository
        .isOnboardingCompleted();
    if (!mounted) return;

    if (hasCompletedOnboarding) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo MyFish
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.md,
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Image.asset(
                  'assets/images/myfish.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.water_drop_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Nama Aplikasi
              Semantics(
                header: true,
                child: Text(
                  'MyFish',
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                  'Monitoring & Kontrol Pakan Ikan Otomatis',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              // Indikator loading melingkar
              Semantics(
                label: 'Memuat…',
                child: const SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
