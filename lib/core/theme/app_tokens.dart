import 'package:flutter/material.dart';

/// Spacing kelipatan 4 (DESIGN.md §3).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Margin layar.
  static const double screen = lg;

  /// Jarak antar kartu.
  static const double cardGap = md;

  /// Padding kartu.
  static const double card = lg;

  /// Lebar konten maksimum untuk tablet/desktop (DESIGN.md §9).
  static const double maxContentWidth = 560;
}

/// Radius (DESIGN.md §3).
abstract final class AppRadius {
  static const double input = 12;
  static const double chip = 12;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetAll = BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Shadow (DESIGN.md §3).
abstract final class AppShadows {
  /// `sm`: kartu.
  static const List<BoxShadow> sm = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x0F1565C0), // rgba(21,101,192,0.06)
    ),
  ];

  /// `md`: bottom nav, sheet.
  static const List<BoxShadow> md = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x1A1565C0), // rgba(21,101,192,0.10)
    ),
  ];

  /// Tombol primer.
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 16,
      color: Color(0x4D1976D2), // rgba(25,118,210,0.30)
    ),
  ];
}

/// Ukuran sentuh & ikon (DESIGN.md §3).
abstract final class AppSizes {
  static const double minTouch = 48;
  static const double icon = 24;
  static const double buttonHeight = 52;
  static const double focusOutline = 2;
}

/// Durasi standar.
abstract final class AppDurations {
  static const Duration snackbar = Duration(seconds: 3);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
}
