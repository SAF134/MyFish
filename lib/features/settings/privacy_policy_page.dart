import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/app_button.dart';

/// Halaman Kebijakan Privasi aplikasi MyFish.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        title: const Text('Kebijakan Privasi'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                Text(
                  'Komitmen Privasi & Keamanan MyFish',
                  style: textTheme.titleMedium?.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Terakhir diperbarui: 30 Oktober 2026',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSection(
                  context,
                  title: '1. Pengumpulan Data',
                  content: 'Aplikasi MyFish dirancang untuk monitoring dan kontrol perangkat pemberi pakan ikan otomatis berbasis ESP32. Kami hanya mengumpulkan informasi yang diperlukan untuk menghubungkan aplikasi dengan perangkat Anda, yaitu identitas perangkat dan email akun alat yang terdaftar.',
                ),
                _buildSection(
                  context,
                  title: '2. Penggunaan Data',
                  content: 'Data yang tersimpan meliputi status online/offline, jadwal pemberian pakan, serta riwayat pakan (waktu, level takaran, dan durasi). Data riwayat pakan otomatis terhapus setelah 30 hari melalui kebijakan retensi sistem Firestore TTL.',
                ),
                _buildSection(
                  context,
                  title: '3. Keamanan Akun & Perangkat',
                  content: 'Semua komunikasi data terenkripsi dan diverifikasi melalui Firebase Authentication dan Firestore Security Rules. Aksi berisiko seperti reset alat dan kalibrasi takaran mewajibkan verifikasi ulang password akun demi keamanan akuarium atau kolam Anda.',
                ),
                _buildSection(
                  context,
                  title: '4. Hak Pengguna',
                  content: 'Pengguna memiliki kontrol penuh untuk mengubah jadwal pakan, menghapus catatan riwayat kapan saja, serta keluar dari akun sewaktu-waktu.',
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
