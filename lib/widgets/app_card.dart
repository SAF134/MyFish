import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Kartu standar: putih, radius 20, bayangan `sm`, padding 16.
///
/// State: default, selected (garis primer), disabled (redup, tak bisa diketuk).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.semanticLabel,
  }) : gradient = null;

  /// Kartu status bergradien (mis. Kartu Status Alat). Teks di dalamnya
  /// otomatis putih.
  const AppCard.gradient({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.semanticLabel,
  }) : selected = false,
       enabled = true;

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isGradient = gradient != null;
    Widget content = Padding(padding: padding, child: child);

    if (isGradient) {
      content = DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.onPrimary),
        child: IconTheme.merge(
          data: const IconThemeData(color: AppColors.onPrimary),
          child: content,
        ),
      );
    }

    final card = AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: isGradient ? null : AppColors.surface,
        gradient: gradient,
        borderRadius: AppRadius.cardAll,
        border: Border.all(
          color: selected
              ? AppColors.primary
              : (isGradient
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppColors.border),
          width: selected ? AppSizes.focusOutline : 1.0,
        ),
        boxShadow: isGradient ? AppShadows.primaryButton : AppShadows.sm,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: enabled ? onTap : null,
          child: content,
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      selected: onTap != null ? selected : null,
      button: onTap != null,
      enabled: enabled,
      child: Opacity(opacity: enabled ? 1 : 0.5, child: card),
    );
  }
}
