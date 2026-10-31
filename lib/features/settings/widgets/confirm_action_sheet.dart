import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/slide_confirm.dart';

/// Modal bottom sheet untuk konfirmasi aksi berisiko menggunakan SlideConfirm
/// setelah melewati verifikasi password (AGENTS.md aturan 1).
class ConfirmActionSheet extends StatelessWidget {
  const ConfirmActionSheet({
    super.key,
    required this.title,
    required this.message,
    required this.slideLabel,
    this.variant = SlideConfirmVariant.normal,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String slideLabel;
  final SlideConfirmVariant variant;
  final Future<void> Function() onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String slideLabel,
    SlideConfirmVariant variant = SlideConfirmVariant.normal,
    required Future<void> Function() onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ConfirmActionSheet(
        title: title,
        message: message,
        slideLabel: slideLabel,
        variant: variant,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDanger = variant == SlideConfirmVariant.danger;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDanger ? AppColors.error : AppColors.text,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context, false),
                tooltip: 'Tutup',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SlideConfirm(
            label: slideLabel,
            variant: variant,
            loadingLabel: 'Memproses perintah…',
            onConfirm: () async {
              await onConfirm();
              if (context.mounted) Navigator.of(context).pop(true);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
