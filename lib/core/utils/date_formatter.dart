/// Helper pemformatan tanggal dan waktu dalam Bahasa Indonesia.
abstract final class DateFormatter {
  static const List<String> _dayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _fullDayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _fullMonthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Mengembalikan singkatan nama hari (Sen, Sel, ...).
  /// [weekday] dari 1 (Senin) hingga 7 (Minggu).
  static String shortDay(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return _dayNames[weekday - 1];
  }

  /// Mengembalikan nama hari lengkap (Senin, Selasa, ...).
  static String fullDay(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return _fullDayNames[weekday - 1];
  }

  /// Mengembalikan nama bulan pendek (Jan, Feb, ...).
  static String shortMonth(int month) {
    if (month < 1 || month > 12) return '';
    return _monthNames[month - 1];
  }

  /// Format "HH:mm" dua digit, misal "07:05".
  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Format tanggal pendek, misal "31 Okt 2026".
  static String formatDate(DateTime dt) {
    final day = dt.day;
    final month = shortMonth(dt.month);
    final year = dt.year;
    return '$day $month $year';
  }

  /// Mengembalikan nama bulan lengkap (Januari, Februari, ...).
  static String fullMonth(int month) {
    if (month < 1 || month > 12) return '';
    return _fullMonthNames[month - 1];
  }

  /// Format tanggal untuk pengelompokan riwayat per hari (Hari Ini, Kemarin, atau nama hari).
  static String formatGroupDate(DateTime dt, [DateTime? referenceNow]) {
    final now = referenceNow ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) {
      return 'Hari Ini, ${dt.day} ${shortMonth(dt.month)} ${dt.year}';
    } else if (diffDays == 1) {
      return 'Kemarin, ${dt.day} ${shortMonth(dt.month)} ${dt.year}';
    } else {
      return '${fullDay(dt.weekday)}, ${dt.day} ${fullMonth(dt.month)} ${dt.year}';
    }
  }

  /// Format tanggal lengkap, misal: "30 Okt 2026, 14:30".
  static String formatDateTime(DateTime dt) {
    final day = dt.day;
    final month = shortMonth(dt.month);
    final year = dt.year;
    final time = formatTime(dt);
    return '$day $month $year, $time';
  }
}
