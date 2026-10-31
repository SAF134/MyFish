import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import 'app_button.dart';
import 'app_card.dart';

/// State kosong: ikon + judul + deskripsi + aksi opsional.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: icon,
      iconColor: AppColors.primary,
      iconBackground: AppColors.primaryTint,
      title: title,
      message: message,
      action: actionLabel != null && onAction != null
          ? AppButton.primary(
              label: actionLabel!,
              onPressed: onAction,
              expanded: false,
            )
          : null,
    );
  }
}

/// State error: pesan + tombol "Coba lagi".
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = 'Gagal memuat',
    this.message,
    required this.onRetry,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: _StateView(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        iconBackground: AppColors.error.withValues(alpha: 0.1),
        title: title,
        message: message,
        action: onRetry == null
            ? null
            : AppButton.secondary(
                label: 'Coba lagi',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                expanded: false,
              ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: ExcludeSemantics(
              child: Icon(icon, color: iconColor, size: 32),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
