import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/device_models.dart';
import '../../../widgets/status_badge.dart';

/// Kartu status alat bergradien (DESIGN.md §6).
class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({
    super.key,
    required this.device,
    this.deviceName = 'ESP32 MyFish',
  });

  final DeviceData? device;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isOnline = device?.isOnline() ?? false;
    final lastSeen = device?.lastSeen;

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

    final borderColor = isOnline ? const Color(0xFF81C784) : const Color(0xFFE57373);
    final primaryTextColor = isOnline ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final secondaryTextColor = isOnline ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final iconBgColor = isOnline
        ? const Color(0xFFA5D6A7).withValues(alpha: 0.6)
        : const Color(0xFFEF9A9A).withValues(alpha: 0.6);

    return Semantics(
      container: true,
      label: isOnline
          ? 'Alat $deviceName Terhubung'
          : 'Alat $deviceName Terputus. $lastSeenText',
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
                        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
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
                            deviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Firmware v${device?.fwVersion ?? "1.0.0"}',
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
            const SizedBox(height: AppSpacing.xl),
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
          ],
        ),
      ),
    );
  }
}
