import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/status_badge.dart';

/// Kartu status alat bergradien (DESIGN.md §6) dengan fitur Segarkan ber-cooldown 60 detik.
class DeviceStatusCard extends StatefulWidget {
  const DeviceStatusCard({
    super.key,
    required this.device,
    this.deviceName = 'ESP32 MyFish',
    this.onRefresh,
  });

  final DeviceData? device;
  final String deviceName;
  final Future<void> Function()? onRefresh;

  @override
  State<DeviceStatusCard> createState() => _DeviceStatusCardState();
}

class _DeviceStatusCardState extends State<DeviceStatusCard> {
  static const String _cooldownPrefKey = 'device_refresh_cooldown_millis';

  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _checkExistingCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkExistingCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMillis = prefs.getInt(_cooldownPrefKey);
      if (lastMillis != null) {
        final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastMillis);
        final elapsed = DateTime.now().difference(lastCheck).inSeconds;
        if (elapsed < 60) {
          if (!mounted) return;
          setState(() {
            _cooldownSeconds = 60 - elapsed;
          });
          _startCooldownTimer();
        }
      }
    } catch (_) {}
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (_cooldownSeconds > 0 || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _cooldownSeconds = 60;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _cooldownPrefKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      _startCooldownTimer();

      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }

      if (mounted) {
        AppSnackbar.info(context, 'Status perangkat sedang disegarkan…');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Gagal menyegarkan status perangkat');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isOnline = widget.device?.isOnline() ?? false;
    final lastSeen = widget.device?.lastSeen;

    final String lastSeenText = lastSeen != null
        ? 'Terakhir terhubung: ${DateFormatter.formatDateTime(lastSeen)}'
        : 'Belum pernah terhubung';

    // Warna status hijau (terhubung) dan merah (terputus)
    final cardBgGradient = isOnline
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          );

    final borderColor =
        isOnline ? const Color(0xFF81C784) : const Color(0xFFE57373);
    final primaryTextColor =
        isOnline ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final secondaryTextColor =
        isOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final iconBgColor = isOnline
        ? const Color(0xFFA5D6A7).withValues(alpha: 0.6)
        : const Color(0xFFEF9A9A).withValues(alpha: 0.6);

    return Semantics(
      container: true,
      label: isOnline
          ? 'Alat ${widget.deviceName} Terhubung'
          : 'Alat ${widget.deviceName} Terputus. $lastSeenText',
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: cardBgGradient,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 280;
                final infoWidget = Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        color: primaryTextColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.deviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Firmware v${widget.device?.fwVersion ?? "1.0.0"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final badge = StatusBadge(
                  status: isOnline ? DeviceStatus.online : DeviceStatus.offline,
                  onDark: false,
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoWidget,
                      const SizedBox(height: AppSpacing.sm),
                      badge,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: infoWidget),
                    const SizedBox(width: AppSpacing.sm),
                    badge,
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isOnline ? 'Terhubung' : 'Terputus',
              style: textTheme.headlineSmall?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isOnline
                  ? 'Alat siap menerima perintah pakan otomatis & manual.'
                  : lastSeenText,
              style: textTheme.bodyMedium?.copyWith(
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(color: borderColor.withValues(alpha: 0.6), height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Tombol Segarkan Perangkat dengan Cooldown 60 Detik
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _cooldownSeconds > 0
                        ? 'Tunggu ${_cooldownSeconds}d sebelum menyegarkan'
                        : 'Periksa status koneksi ESP32',
                    style: textTheme.labelSmall?.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    onTap: (_cooldownSeconds > 0 || _isRefreshing)
                        ? null
                        : _handleRefresh,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _cooldownSeconds > 0
                            ? AppColors.surfaceAlt.withValues(alpha: 0.6)
                            : AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        border: Border.all(
                          color: _cooldownSeconds > 0
                              ? AppColors.border
                              : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 15,
                            color: _cooldownSeconds > 0
                                ? AppColors.textMuted
                                : primaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _cooldownSeconds > 0
                                ? '${_cooldownSeconds}s'
                                : 'Segarkan',
                            style: textTheme.labelSmall?.copyWith(
                              color: _cooldownSeconds > 0
                                  ? AppColors.textMuted
                                  : primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
