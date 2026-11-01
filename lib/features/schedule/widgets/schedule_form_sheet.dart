import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_button.dart';

/// Bottom sheet untuk Tambah atau Ubah Jadwal pakan (DESIGN.md §6).
class ScheduleFormSheet extends StatefulWidget {
  const ScheduleFormSheet({
    super.key,
    this.initialItem,
    required this.existingSchedules,
    required this.onSave,
  });

  final ScheduleItem? initialItem;
  final List<ScheduleItem> existingSchedules;
  final Future<void> Function(String time, int level) onSave;

  static Future<void> show(
    BuildContext context, {
    ScheduleItem? initialItem,
    required List<ScheduleItem> existingSchedules,
    required Future<void> Function(String time, int level) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ScheduleFormSheet(
        initialItem: initialItem,
        existingSchedules: existingSchedules,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet> {
  late TimeOfDay _selectedTime;
  late int _selectedLevel;
  String? _errorMessage;
  bool _isSaving = false;

  bool get _isEdit => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      final parts = widget.initialItem!.time.split(':');
      final hour = int.tryParse(parts[0]) ?? 7;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
      _selectedLevel = widget.initialItem!.level;
    } else {
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _selectedLevel = 1;
    }
  }

  String get _formattedTime {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    final timeStr = _formattedTime;

    // Validasi batas maksimal 10 jadwal jika membuat baru
    if (!_isEdit &&
        widget.existingSchedules.length >= AppConstants.maxScheduleCount) {
      setState(() {
        _errorMessage =
            'Maksimal ${AppConstants.maxScheduleCount} jadwal telah tercapai. Hapus salah satu jadwal terlebih dahulu.';
      });
      return;
    }

    // Validasi jam tidak boleh ganda (AGENTS.md & PRD)
    final isDuplicate = widget.existingSchedules.any((s) {
      if (_isEdit && s.id == widget.initialItem!.id) return false;
      return s.time == timeStr;
    });

    if (isDuplicate) {
      setState(() {
        _errorMessage = 'Jam sudah dipakai. Pilih jam yang berbeda.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(timeStr, _selectedLevel);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Gagal menyimpan jadwal. Coba lagi.';
        });
      }
    }
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
                _isEdit ? 'Ubah Jadwal' : 'Tambah Jadwal',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                tooltip: 'Tutup',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Atur jam pemberian pakan dan takaran dosis servo.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Pemilih Jam (Time Picker Card)
          Text(
            'JAM PEMBERIAN PAKAN',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: _isSaving ? null : _pickTime,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: _errorMessage != null
                      ? AppColors.error
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        _formattedTime,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Ubah Jam',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Pemilih Level Takaran 1 - 5
          Text(
            'TAKARAN DOSIS',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
                      onTap: _isSaving
                          ? null
                          : () => setState(() => _selectedLevel = level),
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
          const SizedBox(height: AppSpacing.xl),

          // Pesan Error jika ada (misal "Jam sudah dipakai")
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

          // Tombol Simpan
          AppButton.primary(
            label: _isEdit ? 'Simpan Perubahan' : 'Simpan Jadwal',
            isLoading: _isSaving,
            loadingLabel: 'Menyimpan…',
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
