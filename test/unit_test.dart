import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfish/core/constants/app_constants.dart';
import 'package:myfish/core/theme/app_theme.dart';
import 'package:myfish/data/models/device_models.dart';
import 'package:myfish/features/history/widgets/history_card.dart';
import 'package:myfish/features/home/widgets/device_status_card.dart';
import 'package:myfish/features/home/widgets/today_schedules_section.dart';
import 'package:myfish/features/schedule/widgets/schedule_card.dart';

void main() {
  group('Unit Test - Logika Penting MyFish', () {
    // 1. Status Online ESP32 (AGENTS.md: online jika lastSeen < 90 detik)
    test('DeviceData.isOnline menghitung batas 90 detik secara tepat', () {
      final now = DateTime(2026, 10, 31, 12, 0, 0);

      // Terhubung 30 dtk yang lalu -> Online
      final dev30s = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: now.subtract(const Duration(seconds: 30)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      expect(dev30s.isOnline(now), isTrue);

      // Terhubung 89 dtk yang lalu -> Online
      final dev89s = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: now.subtract(const Duration(seconds: 89)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      expect(dev89s.isOnline(now), isTrue);

      // Terhubung tepat 90 dtk yang lalu -> Offline
      final dev90s = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: now.subtract(const Duration(seconds: 90)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      expect(dev90s.isOnline(now), isFalse);

      // Terhubung 120 dtk yang lalu -> Offline
      final dev120s = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: now.subtract(const Duration(seconds: 120)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      expect(dev120s.isOnline(now), isFalse);

      // lastSeen null -> Offline
      const devNull = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: null,
        fwVersion: '1.0.0',
        calibration: {},
      );
      expect(devNull.isOnline(now), isFalse);
    });

    // 2. Validasi Jadwal Duplikat (PRD.md & AGENTS.md: jam tidak boleh ganda)
    test('Validasi jadwal mencegah penambahan jam ganda', () {
      final existingSchedules = [
        const ScheduleItem(id: '1', time: '07:00', level: 1, enabled: true),
        const ScheduleItem(id: '2', time: '12:30', level: 2, enabled: true),
        const ScheduleItem(id: '3', time: '17:00', level: 3, enabled: true),
      ];

      bool hasDuplicateTime(String newTime, {String? excludeId}) {
        return existingSchedules.any(
          (s) => s.id != excludeId && s.time == newTime,
        );
      }

      // Jam yang sudah ada harus ditolak
      expect(hasDuplicateTime('07:00'), isTrue);
      expect(hasDuplicateTime('12:30'), isTrue);
      expect(hasDuplicateTime('17:00'), isTrue);

      // Jam yang belum ada harus diterima
      expect(hasDuplicateTime('08:00'), isFalse);
      expect(hasDuplicateTime('07:01'), isFalse);

      // Saat mengedit jadwal sendiri, jam sama diperbolehkan
      expect(hasDuplicateTime('07:00', excludeId: '1'), isFalse);
      expect(hasDuplicateTime('12:30', excludeId: '1'), isTrue);
    });

    // 3. Rentang Kalibrasi & Validasi Monotonik Naik (DESIGN.md: 0.1–10 dtk, naik antar level)
    test('Validasi kalibrasi mengharuskan durasi 0.1–10.0 dtk dan naik antar level', () {
      bool isStrictlyIncreasing(List<double> values) {
        if (values.length != 5) return false;
        for (var i = 0; i < values.length; i++) {
          if (values[i] < 0.1 || values[i] > 10.0) return false;
        }
        for (var i = 0; i < values.length - 1; i++) {
          if (values[i] >= values[i + 1]) return false;
        }
        return true;
      }

      // Konfigurasi normal (valid)
      expect(isStrictlyIncreasing([1.0, 2.0, 3.0, 4.0, 5.0]), isTrue);
      expect(isStrictlyIncreasing([0.5, 1.2, 2.5, 4.0, 7.5]), isTrue);

      // Nilai sama antar level -> tidak valid
      expect(isStrictlyIncreasing([1.0, 2.0, 2.0, 4.0, 5.0]), isFalse);

      // Nilai menurun -> tidak valid
      expect(isStrictlyIncreasing([1.0, 3.0, 2.0, 4.0, 5.0]), isFalse);

      // Nilai di luar rentang (<0.1 atau >10.0) -> tidak valid
      expect(isStrictlyIncreasing([0.05, 1.0, 2.0, 3.0, 4.0]), isFalse);
      expect(isStrictlyIncreasing([1.0, 2.0, 3.0, 4.0, 10.5]), isFalse);
    });

    // 4. Cooldown Tombol Periksa Pembaruan (60 detik)
    test('Logika cooldown 60 detik menghitung sisa waktu secara akurat', () {
      final now = DateTime(2026, 10, 31, 15, 0, 0);

      int calculateRemainingCooldown(DateTime? lastCheck) {
        if (lastCheck == null) return 0;
        final elapsed = now.difference(lastCheck).inSeconds;
        if (elapsed < AppConstants.updateCheckCooldown.inSeconds) {
          return AppConstants.updateCheckCooldown.inSeconds - elapsed;
        }
        return 0;
      }

      // Belum pernah periksa -> 0 dtk
      expect(calculateRemainingCooldown(null), 0);

      // Baru saja periksa 10 dtk lalu -> sisa 50 dtk
      expect(
        calculateRemainingCooldown(now.subtract(const Duration(seconds: 10))),
        50,
      );

      // Periksa 59 dtk lalu -> sisa 1 dtk
      expect(
        calculateRemainingCooldown(now.subtract(const Duration(seconds: 59))),
        1,
      );

      // Periksa tepat 60 dtk lalu -> sisa 0 dtk (cooldown selesai)
      expect(
        calculateRemainingCooldown(now.subtract(const Duration(seconds: 60))),
        0,
      );

      // Periksa 100 dtk lalu -> sisa 0 dtk
      expect(
        calculateRemainingCooldown(now.subtract(const Duration(seconds: 100))),
        0,
      );
    });

    // 5. Semantic Versioning Comparison (AppVersionConfig.isNewer)
    test('AppVersionConfig.isNewer menangani versi mayor, minor, patch', () {
      expect(AppVersionConfig.isNewer('1.0.0', '1.0.1'), isTrue);
      expect(AppVersionConfig.isNewer('1.0.0', '1.1.0'), isTrue);
      expect(AppVersionConfig.isNewer('1.0.0', '2.0.0'), isTrue);
      expect(AppVersionConfig.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(AppVersionConfig.isNewer('1.2.0', '1.1.9'), isFalse);
    });
  });

  group('Aksesibilitas - Uji Skala Font 200%', () {
    testWidgets('DeviceStatusCard mendukung font scale 200% tanpa error', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final device = DeviceData(
        uid: 'esp1',
        status: 'online',
        lastSeen: DateTime.now(),
        fwVersion: '1.0.0',
        calibration: const {},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(body: DeviceStatusCard(device: device)),
          ),
        ),
      );

      expect(find.text('Terhubung'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TodaySchedulesSection mendukung font scale 200%', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const schedules = [
        ScheduleItem(id: '1', time: '07:00', level: 1, enabled: true),
        ScheduleItem(id: '2', time: '12:00', level: 2, enabled: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: TodaySchedulesSection(
                schedules: schedules,
                onViewAll: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Jadwal Hari Ini'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ScheduleCard mendukung font scale 200%', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const item = ScheduleItem(
        id: 's1',
        time: '08:30',
        level: 3,
        enabled: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: ScheduleCard(
                item: item,
                onTap: () {},
                onToggle: (_) {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('08:30'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HistoryCard mendukung font scale 200%', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final item = HistoryItem(
        id: 'h1',
        timestamp: DateTime(2026, 10, 31, 14, 20),
        method: 'manual',
        level: 2,
        durationSec: 2.0,
        expireAt: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: HistoryCard(item: item, canDelete: true, onDelete: () {}),
            ),
          ),
        ),
      );

      expect(find.text('14:20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
