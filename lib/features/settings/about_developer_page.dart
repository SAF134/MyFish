import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';

/// Halaman Tentang Pengembang (DESIGN.md §6 & §7d).
class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  Future<void> _copyText(
    BuildContext context,
    String text,
    String successMessage,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    AppSnackbar.success(context, successMessage);
  }

  Future<void> _launchUri(BuildContext context, String uriString) async {
    final uri = Uri.parse(uriString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'Tidak dapat membuka aplikasi terkait.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
        title: const Text('Tentang Pengembang'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              children: [
                // Foto Bulat Pengembang
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: AppShadows.sm,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/developer.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person_rounded,
                                size: 64,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppConstants.developerName,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Pengembang Perangkat Keras & Lunak MyFish',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Deskripsi Profil
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Singkat',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Halo! Saya Syauqi, pengembang proyek MyFish. Sistem ini dibangun dengan fokus pada keandalan sistem embedded (ESP32) yang dipadukan dengan kemudahan antarmuka aplikasi Android berbasis Flutter & Cloud Firestore. Terima kasih telah menggunakan MyFish untuk menjaga ikan peliharaan Anda tetap sehat dan terawat.',
                        textAlign: TextAlign.justify,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.text,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Kontak Email
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Pengembang',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  AppConstants.developerEmail,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Salin Email',
                              icon: Icons.copy_rounded,
                              onPressed: () => _copyText(
                                context,
                                AppConstants.developerEmail,
                                'Email berhasil disalin ke papan klip',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton.primary(
                              label: 'Kirim Email',
                              icon: Icons.send_rounded,
                              onPressed: () => _launchUri(
                                context,
                                'mailto:${AppConstants.developerEmail}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Kontak WhatsApp
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_outlined,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nomor WhatsApp',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  AppConstants.developerWhatsApp,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Salin Nomor',
                              icon: Icons.copy_rounded,
                              onPressed: () => _copyText(
                                context,
                                AppConstants.developerWhatsApp,
                                'Nomor WhatsApp berhasil disalin ke papan klip',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton.primary(
                              label: 'Chat WhatsApp',
                              icon: Icons.chat_rounded,
                              onPressed: () => _launchUri(
                                context,
                                AppConstants.developerWhatsAppUrl,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
