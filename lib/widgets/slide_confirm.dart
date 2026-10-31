import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Varian tombol geser.
enum SlideConfirmVariant { normal, danger }

/// Tombol geser untuk konfirmasi aksi berisiko (AGENTS.md aturan 1).
///
/// State: idle, dragging, confirmed, loading, disabled.
///
/// Alternatif aksesibel (DESIGN.md §10):
/// - pembaca layar: aksi semantik "Konfirmasi" (ketuk dua kali),
/// - keyboard/switch: fokus lalu Enter/Spasi,
/// - sentuh: tekan-tahan 2 detik.
class SlideConfirm extends StatefulWidget {
  const SlideConfirm({
    super.key,
    required this.label,
    required this.onConfirm,
    this.variant = SlideConfirmVariant.normal,
    this.enabled = true,
    this.loadingLabel = 'Memproses…',
  });

  /// Teks di dalam trek, mis. "Geser untuk beri pakan".
  final String label;

  /// Dipanggil saat dikonfirmasi. Selama future berjalan → state loading.
  final Future<void> Function() onConfirm;
  final SlideConfirmVariant variant;
  final bool enabled;
  final String loadingLabel;

  @override
  State<SlideConfirm> createState() => _SlideConfirmState();
}

class _SlideConfirmState extends State<SlideConfirm> {
  static const double _height = 64;

  bool _loading = false;
  bool _focused = false;

  Color get _color => widget.variant == SlideConfirmVariant.danger
      ? AppColors.error
      : AppColors.primary;

  bool get _canConfirm => widget.enabled && !_loading;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _loading = true);
    try {
      await widget.onConfirm();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final slider = SlideAction(
      height: _height,
      borderRadius: AppRadius.pill,
      elevation: 0,
      enabled: _canConfirm,
      outerColor: _canConfirm ? _color : AppColors.offline,
      innerColor: AppColors.surface,
      sliderRotate: false,
      sliderButtonIconPadding: AppSpacing.md,
      animationDuration: reduceMotion
          ? const Duration(milliseconds: 1)
          : AppDurations.medium,
      sliderButtonIcon: Icon(
        Icons.arrow_forward_rounded,
        color: _canConfirm ? _color : AppColors.offline,
        size: AppSizes.icon,
      ),
      submittedIcon: const Icon(
        Icons.check_rounded,
        color: AppColors.onPrimary,
      ),
      onSubmit: _canConfirm
          ? () {
              // Jangan di-await: SlideAction mereset dirinya sendiri, sementara
              // lapisan loading menutupinya sampai onConfirm selesai.
              unawaited(_confirm());
              return null;
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _height + AppSpacing.sm,
          right: AppSpacing.lg,
        ),
        child: Text(
          widget.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );

    final track = Stack(
      children: [
        slider,
        if (_loading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _color,
                borderRadius: AppRadius.pillAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    widget.loadingLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          enabled: _canConfirm,
          label: _loading ? widget.loadingLabel : widget.label,
          hint: 'Ketuk dua kali untuk konfirmasi',
          onTap: _canConfirm ? _confirm : null,
          excludeSemantics: true,
          child: FocusableActionDetector(
            enabled: _canConfirm,
            onShowFocusHighlight: (v) => setState(() => _focused = v),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _confirm();
                  return null;
                },
              ),
            },
            child: RawGestureDetector(
              gestures: {
                LongPressGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      LongPressGestureRecognizer
                    >(
                      () => LongPressGestureRecognizer(
                        duration: AppConstants.slideLongPressDuration,
                      ),
                      (r) => r.onLongPress = _canConfirm ? _confirm : null,
                    ),
              },
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.all(AppSizes.focusOutline),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: _focused ? AppColors.primary : Colors.transparent,
                    width: AppSizes.focusOutline,
                  ),
                ),
                child: track,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ExcludeSemantics(
          child: Text(
            'Geser untuk konfirmasi · atau tekan-tahan 2 detik',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
