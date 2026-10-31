import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/auth_repository.dart';
import '../../widgets/app_button.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

/// Halaman Onboarding 3 slide (Pantau Alat, Atur Jadwal, Riwayat Pakan).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Pantau Status Alat',
      description: 'Ketahui kondisi alat pemberi pakan ikan Anda kapan saja secara realtime dari genggaman.',
      icon: Icons.sensors_rounded,
    ),
    _OnboardingSlide(
      title: 'Atur Jadwal Otomatis',
      description: 'Buat jadwal pakan harian dengan takaran dosis presisi agar ikan selalu kenyang tepat waktu.',
      icon: Icons.alarm_on_rounded,
    ),
    _OnboardingSlide(
      title: 'Riwayat Pakan Lengkap',
      description: 'Catatan pemberian pakan otomatis dan manual tersimpan rapi beserta grafik tren mingguan.',
      icon: Icons.insights_rounded,
    ),
  ];

  Future<void> _completeOnboarding() async {
    await _authRepository.setOnboardingCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          if (!isLastPage)
            AppButton.text(label: 'Lewati', onPressed: _completeOnboarding),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screen,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ilustrasi visual 60% proporsi area
                        Expanded(
                          flex: 6,
                          child: Center(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.md,
                              ),
                              child: Center(
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 72,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Konten teks
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                slide.description,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indikator titik & tombol aksi bawah
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: isLastPage ? 'Mulai' : 'Lanjut',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
