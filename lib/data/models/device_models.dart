import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

/// Data status dan kalibrasi perangkat dari dokumen `devices/{uid}`.
class DeviceData {
  const DeviceData({
    required this.uid,
    required this.status,
    required this.lastSeen,
    required this.fwVersion,
    required this.calibration,
  });

  factory DeviceData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawLastSeen = data['lastSeen'];
    DateTime? lastSeen;
    if (rawLastSeen is Timestamp) {
      lastSeen = rawLastSeen.toDate();
    } else if (rawLastSeen is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(rawLastSeen);
    }

    final rawCalib = data['calibration'];
    final calib = <String, double>{};
    if (rawCalib is Map) {
      rawCalib.forEach((k, v) {
        if (v is num) calib[k.toString()] = v.toDouble();
      });
    }

    return DeviceData(
      uid: doc.id,
      status: (data['status'] as String?)?.toLowerCase() ?? 'offline',
      lastSeen: lastSeen,
      fwVersion: (data['fwVersion'] as String?) ?? '1.0.0',
      calibration: calib,
    );
  }

  final String uid;
  final String status;
  final DateTime? lastSeen;
  final String fwVersion;
  final Map<String, double> calibration;

  /// Alat dianggap online jika `lastSeen` < 90 detik dari sekarang (AGENTS.md).
  bool isOnline([DateTime? now]) {
    if (lastSeen == null) return false;
    final current = now ?? DateTime.now();
    return current.difference(lastSeen!).abs() < AppConstants.onlineThreshold;
  }
}

/// Jadwal pemberian pakan dari subkoleksi `devices/{uid}/schedules/{id}`.
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.time,
    required this.level,
    required this.enabled,
  });

  factory ScheduleItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ScheduleItem(
      id: doc.id,
      time: (data['time'] as String?) ?? '00:00',
      level: (data['level'] as num?)?.toInt().clamp(1, 5) ?? 1,
      enabled: (data['enabled'] as bool?) ?? true,
    );
  }

  final String id;
  final String time; // "HH:mm"
  final int level; // 1-5
  final bool enabled;

  ScheduleItem copyWith({String? id, String? time, int? level, bool? enabled}) {
    return ScheduleItem(
      id: id ?? this.id,
      time: time ?? this.time,
      level: level ?? this.level,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'time': time,
    'level': level,
    'enabled': enabled,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time &&
          level == other.level &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(id, time, level, enabled);
}

/// Riwayat pemberian pakan dari subkoleksi `devices/{uid}/history/{id}`.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.level,
    required this.durationSec,
    required this.expireAt,
  });

  factory HistoryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawTs = data['timestamp'];
    DateTime timestamp = DateTime.now();
    if (rawTs is Timestamp) {
      timestamp = rawTs.toDate();
    } else if (rawTs is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(rawTs);
    }

    final rawExp = data['expireAt'];
    DateTime? expireAt;
    if (rawExp is Timestamp) {
      expireAt = rawExp.toDate();
    }

    return HistoryItem(
      id: doc.id,
      timestamp: timestamp,
      method: (data['method'] as String?)?.toLowerCase() ?? 'auto',
      level: (data['level'] as num?)?.toInt().clamp(1, 5) ?? 1,
      durationSec: (data['durationSec'] as num?)?.toDouble() ?? 1.0,
      expireAt: expireAt,
    );
  }

  final String id;
  final DateTime timestamp;
  final String method; // "auto" | "manual"
  final int level; // 1-5
  final double durationSec;
  final DateTime? expireAt;

  bool get isAuto => method == 'auto';
}

/// Dokumen perintah ke alat dari subkoleksi `devices/{uid}/commands/{id}`.
class DeviceCommand {
  const DeviceCommand({
    required this.id,
    required this.type,
    required this.level,
    required this.status,
    required this.createdAt,
  });

  factory DeviceCommand.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    }

    return DeviceCommand(
      id: doc.id,
      type: (data['type'] as String?)?.toLowerCase() ?? 'feed',
      level: (data['level'] as num?)?.toInt(),
      status: (data['status'] as String?)?.toLowerCase() ?? 'pending',
      createdAt: createdAt,
    );
  }

  final String id;
  final String type; // "feed" | "reset" | "shutdown"
  final int? level; // 1-5
  final String status; // "pending" | "running" | "done" | "failed"
  final DateTime? createdAt;
}

/// Konfigurasi versi aplikasi dari dokumen `app_config/version` (AGENTS.md & PRD.md).
class AppVersionConfig {
  const AppVersionConfig({required this.latest, required this.downloadUrl});

  factory AppVersionConfig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppVersionConfig(
      latest: (data['latest'] as String?) ?? AppConstants.appVersion,
      downloadUrl: (data['downloadUrl'] as String?) ?? AppConstants.downloadUrl,
    );
  }

  final String latest;
  final String downloadUrl;

  /// Memeriksa apakah versi [latest] lebih baru dari versi [current].
  static bool isNewer(String current, String latest) {
    final currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    final maxLen = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var i = 0; i < maxLen; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}
