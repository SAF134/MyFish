import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';

/// Halaman Dukung Pengembang (DESIGN.md §6 & §7e).
class SupportDeveloperPage extends StatefulWidget {
  const SupportDeveloperPage({super.key, this.onSaveQris, this.onShareQris});

  final Future<void> Function()? onSaveQris;
  final Future<void> Function()? onShareQris;

  @override
  State<SupportDeveloperPage> createState() => _SupportDeveloperPageState();
}

class _SupportDeveloperPageState extends State<SupportDeveloperPage> {
  bool _isSaving = false;
  bool _isSharing = false;

  Future<Uint8List> _loadQrisBytes() async {
    final byteData = await rootBundle.load('assets/images/qris.png');
    return byteData.buffer.asUint8List();
  }

  Future<void> _saveQrisToGallery() async {
    setState(() => _isSaving = true);
    if (widget.onSaveQris != null) {
      try {
        await widget.onSaveQris!();
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
      return;
    }

    try {
      final bytes = await _loadQrisBytes();
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'MyFish_QRIS_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      if (result != null &&
          (result['isSuccess'] == true || result['filePath'] != null)) {
        AppSnackbar.success(context, 'Gambar QRIS berhasil disimpan ke galeri');
      } else {
        AppSnackbar.success(context, 'Gambar QRIS telah disimpan ke perangkat');
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal menyimpan gambar QRIS ke galeri');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareQris() async {
    setState(() => _isSharing = true);
    if (widget.onShareQris != null) {
      try {
        await widget.onShareQris!();
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
      return;
    }

    try {
      final bytes = await _loadQrisBytes();
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 'myfish_qris.png',
            ),
          ],
          text: 'Dukung pengembangan dan pemeliharaan aplikasi MyFish melalui kode QRIS berikut. Terima kasih atas dukungan Anda!',
        ),
      );
    } catch (_) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: 'Dukung pengembangan aplikasi MyFish melalui QRIS. Terima kasih atas donasi dan apresiasi Anda!',
          ),
        );
      } catch (e) {
        if (!mounted) return;
        AppSnackbar.error(context, 'Tidak dapat membuka menu berbagi');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
        title: const Text('Dukung Pengembang'),
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
                // Deskripsi Pengantar
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
                              color: AppColors.primaryTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.primaryDark,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Apresiasi & Donasi',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Setiap kontribusi dan dukungan dari Anda sangat berarti untuk membantu kelanjutan riset perangkat IoT, pemeliharaan server database, dan penambahan fitur baru pada aplikasi MyFish.',
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

                // Kartu Gambar QRIS (Kontras tinggi, latar putih bersih)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.sm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'QRIS STANDAR PEMBAYARAN NASIONAL',
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          label: 'Kode QRIS pengembang',
                          image: true,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.input,
                            ),
                            child: Image.asset(
                              'assets/images/qris.png',
                              width: 260,
                              height: 260,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 260,
                                    height: 260,
                                    color: AppColors.surfaceAlt,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 100,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Mendukung Gopay, OVO, Dana, ShopeePay, BCA, Mandiri, BRI, BNI & seluruh mobile banking.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Tombol Simpan QRIS & Bagikan
                AppButton.primary(
                  label: 'Simpan QRIS ke Galeri',
                  icon: Icons.download_rounded,
                  isLoading: _isSaving,
                  loadingLabel: 'Menyimpan QRIS…',
                  onPressed: _isSaving ? null : _saveQrisToGallery,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  label: 'Bagikan QRIS',
                  icon: Icons.share_rounded,
                  isLoading: _isSharing,
                  loadingLabel: 'Membuka menu bagikan…',
                  onPressed: _isSharing ? null : _shareQris,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
