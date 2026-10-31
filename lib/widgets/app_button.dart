import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Varian tombol (DESIGN.md §7).
enum AppButtonVariant { primary, secondary, danger, text }

/// Tombol standar MyFish: primer (gradien), sekunder (outline biru),
/// bahaya (outline merah), teks. State: default, pressed, disabled, loading.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.loadingLabel = 'Memuat…',
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.loadingLabel = 'Memuat…',
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.loadingLabel = 'Memuat…',
  }) : variant = AppButtonVariant.secondary;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.loadingLabel = 'Memuat…',
  }) : variant = AppButtonVariant.danger;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
    this.loadingLabel = 'Memuat…',
  }) : variant = AppButtonVariant.text;

  final String label;

  /// `null` = nonaktif.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  /// Label pembaca layar saat loading.
  final String loadingLabel;

  bool get _enabled => onPressed != null && !isLoading;

  Color get _foreground => switch (variant) {
    AppButtonVariant.primary => AppColors.onPrimary,
    AppButtonVariant.secondary => AppColors.primary,
    AppButtonVariant.danger => AppColors.error,
    AppButtonVariant.text => AppColors.primaryDark,
  };

  @override
  Widget build(BuildContext context) {
    final content = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
      color: _foreground,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
        onPressed: _enabled ? onPressed : null,
        child: content,
      ),
      AppButtonVariant.secondary || AppButtonVariant.danger => OutlinedButton(
        onPressed: _enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: _foreground,
          side: BorderSide(
            color: _enabled ? _foreground : AppColors.border,
            width: 1.5,
          ),
          backgroundColor: AppColors.surface,
        ),
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: _enabled ? onPressed : null,
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      label: isLoading ? loadingLabel : null,
      excludeSemantics: isLoading,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.color,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }
    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}

/// Tombol primer bergradien biru + bayangan primer.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: enabled
                ? AppColors.primaryDark.withValues(alpha: 0.5)
                : AppColors.border,
            width: 1.0,
          ),
          boxShadow: enabled ? AppShadows.primaryButton : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            focusColor: AppColors.primaryDark,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.buttonHeight,
                minWidth: AppSizes.minTouch,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  widthFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: textStyle?.copyWith(color: AppColors.onPrimary),
                    child: IconTheme.merge(
                      data: const IconThemeData(color: AppColors.onPrimary),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon bulat (kembali, menu) dengan label Semantics wajib.
class AppCircleIconButton extends StatelessWidget {
  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  /// Tombol kembali standar.
  factory AppCircleIconButton.back({Key? key, VoidCallback? onPressed}) =>
      AppCircleIconButton(
        key: key,
        icon: Icons.arrow_back_ios_new_rounded,
        semanticLabel: 'Kembali',
        onPressed: onPressed,
      );

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: semanticLabel,
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.border, width: 1.0),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed ?? () => Navigator.maybePop(context),
            child: SizedBox.square(
              dimension: AppSizes.minTouch,
              child: Icon(icon, size: 20, color: AppColors.text),
            ),
          ),
        ),
      ),
    );
  }
}
