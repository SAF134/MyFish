/// Konstanta aplikasi MyFish (PRD.md & DESIGN.md).
abstract final class AppConstants {
  static const String appName = 'MyFish';
  static const String appTagline =
      'Monitoring & Kontrol Pemberi Pakan Ikan Otomatis';
  static const String appVersion = '1.0.0';

  /// Tautan unduh aplikasi MyFish (Google Drive).
  static const String downloadUrl =
      'https://drive.google.com/drive/folders/1FhioI8ia7Oa8s7rQgqq_cohsXmGCVRXW?usp=drive_link';

  /// Informasi kontak pengembang.
  static const String developerName = 'SAF';
  static const String developerEmail = 'syauqiakmal137@gmail.com';
  static const String developerWhatsApp = '081298628236';
  static const String developerWhatsAppUrl = 'https://wa.me/6281298628236';

  /// Alat dianggap online jika `lastSeen` < 90 dtk dari sekarang.
  static const Duration onlineThreshold = Duration(seconds: 90);

  /// Alat membatalkan perintah yang lebih tua dari 30 dtk.
  static const Duration commandTimeout = Duration(seconds: 30);

  /// Riwayat dihapus otomatis oleh TTL Firestore setelah 30 hari.
  static const Duration historyRetention = Duration(days: 30);

  /// Cooldown tombol Periksa Pembaruan.
  static const Duration updateCheckCooldown = Duration(seconds: 60);

  /// Durasi tekan-tahan alternatif untuk tombol geser.
  static const Duration slideLongPressDuration = Duration(seconds: 2);
}
