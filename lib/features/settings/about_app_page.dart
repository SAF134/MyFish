import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';

/// Halaman Tentang Aplikasi (DESIGN.md §6 & §7c).
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  Future<void> _copyDownloadUrl(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: AppConstants.downloadUrl),
    );
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Tautan unduh berhasil disalin');
  }

  Future<void> _openDownloadUrl(BuildContext context) async {
    final uri = Uri.parse(AppConstants.downloadUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'Tidak dapat membuka tautan peramban.');
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
        title: const Text('Tentang Aplikasi'),
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
                // Header Logo, Nama & Tagline
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          boxShadow: AppShadows.sm,
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Image.asset(
                          'assets/images/myfish.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.set_meal_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppConstants.appName,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          'Versi ${AppConstants.appVersion}',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Deskripsi Aplikasi
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deskripsi',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'MyFish adalah aplikasi pintar berbasis Android untuk memantau dan mengontrol perangkat pemberi pakan ikan otomatis berbasis ESP32 dan Cloud Firestore. Dirancang dengan tampilan Material 3 modern untuk memastikan kebutuhan nutrisi ikan peliharaan atau budidaya Anda tetap terpenuhi tepat waktu, tepat takaran, dan terpantau kapan saja.',
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

                // Daftar Fitur Unggulan
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fitur Unggulan',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FeatureItem(
                        icon: Icons.sensors_rounded,
                        title: 'Monitoring Realtime',
                        description: 'Pantau status koneksi online/offline ESP32 dan versi firmware secara akurat.',
                      ),
                      const Divider(height: AppSpacing.xl),
                      _FeatureItem(
                        icon: Icons.restaurant_rounded,
                        title: 'Pemberian Pakan Manual',
                        description: 'Pemberian pakan instan dengan 5 level dosis dan perlindungan tombol geser.',
                      ),
                      const Divider(height: AppSpacing.xl),
                      _FeatureItem(
                        icon: Icons.alarm_rounded,
                        title: 'Penjadwalan Otomatis',
                        description: 'Atur hingga 10 jadwal pakan harian terprogram tanpa kekhawatiran jam ganda.',
                      ),
                      const Divider(height: AppSpacing.xl),
                      _FeatureItem(
                        icon: Icons.bar_chart_rounded,
                        title: 'Riwayat & Grafik 7 Hari',
                        description: 'Visualisasi frekuensi pakan mingguan dan log hingga 25 riwayat pakan terakhir.',
                      ),
                      const Divider(height: AppSpacing.xl),
                      _FeatureItem(
                        icon: Icons.tune_rounded,
                        title: 'Kalibrasi Takaran Presisi',
                        description: 'Kustomisasi durasi putaran servo per level dosis dengan sistem keamanan password.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Link Unduh Aplikasi
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.cloud_download_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Tautan Unduh Aplikasi',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bagikan tautan Google Drive ini agar rekan Anda dapat mengunduh dan memasang aplikasi MyFish.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppConstants.downloadUrl,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Salin Tautan',
                              icon: Icons.copy_rounded,
                              onPressed: () => _copyDownloadUrl(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton.primary(
                              label: 'Buka Link',
                              icon: Icons.open_in_new_rounded,
                              onPressed: () => _openDownloadUrl(context),
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

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
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
    );
  }
}
