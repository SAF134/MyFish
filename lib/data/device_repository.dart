import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/device_models.dart';

/// Model item direktori alat dari koleksi `device_directory`.
class DeviceDirectoryItem {
  const DeviceDirectoryItem({
    required this.id,
    required this.name,
    required this.email,
  });

  factory DeviceDirectoryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DeviceDirectoryItem(
      id: doc.id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : 'Alat ${doc.id}',
      email: (data['email'] as String?)?.trim() ?? '',
    );
  }

  final String id;
  final String name;
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceDirectoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, email);
}

/// Repository untuk mengakses data `devices`, `schedules`, `history`, dan `commands`
/// di Firestore sesuai spesifikasi AGENTS.md.
class DeviceRepository {
  DeviceRepository({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Mengambil daftar akun alat publik dari koleksi `device_directory`.
  Future<List<DeviceDirectoryItem>> getDeviceDirectory() async {
    final snapshot = await _firestore
        .collection('device_directory')
        .get(const GetOptions(source: Source.serverAndCache));

    return snapshot.docs
        .map((doc) => DeviceDirectoryItem.fromFirestore(doc))
        .where((item) => item.email.isNotEmpty)
        .toList();
  }

  /// Mengambil informasi nama alat berdasarkan ID dokumen `device_directory`.
  Future<DeviceDirectoryItem?> getDeviceDirectoryItem(String id) async {
    try {
      final doc = await _firestore.collection('device_directory').doc(id).get();
      if (!doc.exists) return null;
      return DeviceDirectoryItem.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  /// Memantau dokumen alat secara realtime `devices/{uid}`.
  Stream<DeviceData?> watchDevice(String uid) {
    return _firestore.collection('devices').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DeviceData.fromFirestore(doc);
    });
  }

  /// Memantau jadwal pakan secara realtime `devices/{uid}/schedules`.
  /// Jadwal diurutkan berdasarkan jam (HH:mm).
  Stream<List<ScheduleItem>> watchSchedules(String uid) {
    return _firestore
        .collection('devices')
        .doc(uid)
        .collection('schedules')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((d) => ScheduleItem.fromFirestore(d))
              .toList();
          items.sort((a, b) => a.time.compareTo(b.time));
          return items;
        });
  }

  /// Menambahkan jadwal pakan baru ke `devices/{uid}/schedules`.
  Future<String> addSchedule(
    String uid, {
    required String time,
    required int level,
    bool enabled = true,
  }) async {
    final docRef = await _firestore
        .collection('devices')
        .doc(uid)
        .collection('schedules')
        .add({'time': time, 'level': level.clamp(1, 5), 'enabled': enabled});
    return docRef.id;
  }

  /// Memperbarui jadwal pakan di `devices/{uid}/schedules/{id}`.
  Future<void> updateSchedule(
    String uid, {
    required String id,
    required String time,
    required int level,
    required bool enabled,
  }) async {
    await _firestore
        .collection('devices')
        .doc(uid)
        .collection('schedules')
        .doc(id)
        .update({'time': time, 'level': level.clamp(1, 5), 'enabled': enabled});
  }

  /// Mengubah status aktif/nonaktif jadwal pakan `devices/{uid}/schedules/{id}`.
  Future<void> toggleSchedule(
    String uid, {
    required String id,
    required bool enabled,
  }) async {
    await _firestore
        .collection('devices')
        .doc(uid)
        .collection('schedules')
        .doc(id)
        .update({'enabled': enabled});
  }

  /// Menghapus dokumen jadwal pakan dari `devices/{uid}/schedules/{id}`.
  Future<void> deleteSchedule(String uid, String id) async {
    await _firestore
        .collection('devices')
        .doc(uid)
        .collection('schedules')
        .doc(id)
        .delete();
  }

  /// Memantau riwayat pakan secara realtime `devices/{uid}/history`.
  Stream<List<HistoryItem>> watchHistory(String uid, {int limit = 50}) {
    return _firestore
        .collection('devices')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((d) => HistoryItem.fromFirestore(d))
              .toList();
        });
  }

  /// Menghapus dokumen item riwayat pakan dari `devices/{uid}/history/{id}`.
  Future<void> deleteHistoryItem(String uid, String id) async {
    await _firestore
        .collection('devices')
        .doc(uid)
        .collection('history')
        .doc(id)
        .delete();
  }

  /// Membuat dokumen perintah pakan manual di `devices/{uid}/commands`.
  /// Status awal: "pending", waktu pembuatan: serverTimestamp.
  Future<String> sendFeedCommand(String uid, int level) async {
    final docRef = await _firestore
        .collection('devices')
        .doc(uid)
        .collection('commands')
        .add({
          'type': 'feed',
          'level': level,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
    return docRef.id;
  }

  /// Membuat dokumen perintah reset mikrokontroler di `devices/{uid}/commands`.
  Future<String> sendResetCommand(String uid) async {
    final docRef = await _firestore
        .collection('devices')
        .doc(uid)
        .collection('commands')
        .add({
          'type': 'reset',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
    return docRef.id;
  }

  /// Membuat dokumen perintah matikan (deep sleep) mikrokontroler di `devices/{uid}/commands`.
  Future<String> sendShutdownCommand(String uid) async {
    final docRef = await _firestore
        .collection('devices')
        .doc(uid)
        .collection('commands')
        .add({
          'type': 'shutdown',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
    return docRef.id;
  }

  /// Memperbarui nilai durasi kalibrasi servo level 1–5 di `devices/{uid}`.
  Future<void> updateCalibration(
    String uid,
    Map<String, double> calibration,
  ) async {
    await _firestore.collection('devices').doc(uid).set({
      'calibration': calibration,
    }, SetOptions(merge: true));
  }

  /// Memantau perubahan status dokumen perintah tertentu `devices/{uid}/commands/{commandId}`.
  Stream<DeviceCommand?> watchCommand(String uid, String commandId) {
    return _firestore
        .collection('devices')
        .doc(uid)
        .collection('commands')
        .doc(commandId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return DeviceCommand.fromFirestore(doc);
        });
  }

  /// Mengambil konfigurasi pembaruan aplikasi dari `app_config/version`.
  Future<AppVersionConfig?> checkAppVersion() async {
    final doc = await _firestore.collection('app_config').doc('version').get();
    if (!doc.exists) return null;
    return AppVersionConfig.fromFirestore(doc);
  }
}
