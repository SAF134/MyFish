import 'package:flutter/material.dart';

/// Token warna dari DESIGN.md §3. Jangan hardcode warna di luar file ini.
abstract final class AppColors {
  static const Color bg = Color(0xFFEEF2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F7FB);
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);

  /// Dekoratif saja (batang chart, gradien) — jangan untuk teks.
  static const Color primaryLight = Color(0xFF4FA3F7);
  static const Color primaryTint = Color(0xFFDCEBFC);
  static const Color text = Color(0xFF0F1B2D);
  static const Color textMuted = Color(0xFF56657A);
  static const Color border = Color(0xFFDDE5EF);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color error = Color(0xFFC62828);
  static const Color offline = Color(0xFF6B7280);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Gradien primer: kiri-atas → kanan-bawah.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Gradien kartu status saat offline (abu).
  static const LinearGradient offlineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [offline, Color(0xFF4B5563)],
  );

  /// Latar layar pembuka: biru muda → putih.
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryTint, surface],
  );
}
