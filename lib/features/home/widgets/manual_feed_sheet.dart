import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/device_repository.dart';
import '../../../widgets/slide_confirm.dart';

/// Bottom Sheet untuk memilih level takaran dan konfirmasi pakan manual via SlideConfirm.
class ManualFeedSheet extends StatefulWidget {
  const ManualFeedSheet({
    super.key,
    required this.uid,
    required this.deviceRepository,
  });

  final String uid;
  final DeviceRepository deviceRepository;

  static Future<int?> show(
    BuildContext context, {
    required String uid,
    required DeviceRepository deviceRepository,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          ManualFeedSheet(uid: uid, deviceRepository: deviceRepository),
    );
  }

  @override
  State<ManualFeedSheet> createState() => _ManualFeedSheetState();
}

class _ManualFeedSheetState extends State<ManualFeedSheet> {
  int _selectedLevel = 1;
  bool _isProcessing = false;
  String _processMessage = 'Menunggu alat…';
  String? _errorMessage;

  StreamSubscription? _commandSubscription;
  Timer? _timeoutTimer;

  @override
  void dispose() {
    _commandSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _processMessage = 'Mengirim perintah…';
    });

    final completer = Completer<void>();

    try {
      final commandId = await widget.deviceRepository.sendFeedCommand(
        widget.uid,
        _selectedLevel,
      );

      if (!mounted) {
        completer.complete();
        return;
      }

      setState(() => _processMessage = 'Menunggu respon alat…');

      // Pasang timeout 30 detik sesuai PRD & AGENTS.md
      _timeoutTimer = Timer(AppConstants.commandTimeout, () {
        _commandSubscription?.cancel();
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Gagal: alat tidak merespons (waktu habis)';
        });
        if (!completer.isCompleted) completer.complete();
      });

      // Amati status dokumen command secara realtime
      _commandSubscription = widget.deviceRepository
          .watchCommand(widget.uid, commandId)
          .listen(
            (cmd) {
              if (cmd == null || !mounted) return;

              if (cmd.status == 'running') {
                setState(() => _processMessage = 'Alat sedang memberi pakan…');
              } else if (cmd.status == 'done') {
                _timeoutTimer?.cancel();
                _commandSubscription?.cancel();
                if (!completer.isCompleted) completer.complete();
                Navigator.of(context).pop(_selectedLevel);
              } else if (cmd.status == 'failed') {
                _timeoutTimer?.cancel();
                _commandSubscription?.cancel();
                setState(() {
                  _isProcessing = false;
                  _errorMessage = 'Pemberian pakan gagal dieksekusi oleh alat';
                });
                if (!completer.isCompleted) completer.complete();
              }
            },
            onError: (e) {
              _timeoutTimer?.cancel();
              setState(() {
                _isProcessing = false;
                _errorMessage = 'Terjadi kesalahan jaringan saat memantau';
              });
              if (!completer.isCompleted) completer.complete();
            },
          );
    } catch (_) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Gagal mengirim perintah ke alat';
        });
      }
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                'Beri Pakan Manual',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                tooltip: 'Tutup',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pilih level takaran pakan (1–5) lalu geser tombol konfirmasi di bawah.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Selector Level Takaran 1 - 5
          Text(
            'PILIH TAKARAN DOSIS',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = _selectedLevel == level;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 4 ? AppSpacing.sm : 0,
                  ),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Level $level',
                    child: InkWell(
                      onTap: _isProcessing
                          ? null
                          : () {
                              setState(() {
                                _selectedLevel = level;
                                _errorMessage = null;
                              });
                            },
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$level',
                              style: textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.onPrimary
                                    : AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lvl',
                              style: textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? AppColors.onPrimary
                                    : AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Pesan error jika ada
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Tombol geser konfirmasi
          SlideConfirm(
            label: 'Geser untuk pakan (Level $_selectedLevel)',
            loadingLabel: _processMessage,
            enabled: !_isProcessing,
            onConfirm: _handleConfirm,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
