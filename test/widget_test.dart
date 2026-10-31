import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfish/core/theme/app_theme.dart';
import 'package:myfish/data/auth_repository.dart';
import 'package:myfish/data/device_repository.dart';
import 'package:myfish/data/models/device_models.dart';
import 'package:myfish/features/history/history_page.dart';
import 'package:myfish/features/history/widgets/delete_history_sheet.dart';
import 'package:myfish/features/history/widgets/history_card.dart';
import 'package:myfish/features/home/home_page.dart';
import 'package:myfish/features/home/widgets/device_status_card.dart';
import 'package:myfish/features/home/widgets/feeding_chart.dart';
import 'package:myfish/features/home/widgets/recent_history_section.dart';
import 'package:myfish/features/home/widgets/today_schedules_section.dart';
import 'package:myfish/features/login/login_page.dart';
import 'package:myfish/features/onboarding/onboarding_page.dart';
import 'package:myfish/features/schedule/schedule_page.dart';
import 'package:myfish/features/schedule/widgets/delete_schedule_dialog.dart';
import 'package:myfish/features/schedule/widgets/schedule_card.dart';
import 'package:myfish/core/constants/app_constants.dart';
import 'package:myfish/features/schedule/widgets/schedule_form_sheet.dart';
import 'package:myfish/features/settings/about_app_page.dart';
import 'package:myfish/features/settings/about_developer_page.dart';
import 'package:myfish/features/settings/calibration_page.dart';
import 'package:myfish/features/settings/esp32_control_page.dart';
import 'package:myfish/features/settings/privacy_policy_page.dart';
import 'package:myfish/features/settings/settings_page.dart';
import 'package:myfish/features/settings/support_developer_page.dart';
import 'package:myfish/features/splash/splash_page.dart';
import 'package:myfish/widgets/app_button.dart';
import 'package:myfish/widgets/app_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    this.initialUserLoggedIn = false,
    this.initialOnboardingCompleted = false,
    this.mockSignInError,
    this.mockReauthError,
  });

  final bool initialUserLoggedIn;
  bool initialOnboardingCompleted;
  final String? mockSignInError;
  String? mockReauthError;
  bool didSignOut = false;

  @override
  User? get currentUser => initialUserLoggedIn ? null : null;

  @override
  Stream<User?> get authStateChanges => Stream.value(currentUser);

  @override
  Future<bool> isOnboardingCompleted() async => initialOnboardingCompleted;

  @override
  Future<void> setOnboardingCompleted() async {
    initialOnboardingCompleted = true;
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    return mockSignInError;
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }

  @override
  Future<AuthResult> reauthenticate(String password) async {
    return mockReauthError;
  }
}

class FakeDeviceRepository extends DeviceRepository {
  FakeDeviceRepository({
    this.items = const [],
    this.shouldThrow = false,
    this.mockDevice,
    this.mockSchedules = const [],
    this.mockHistory = const [],
    this.mockDirectoryItem,
    this.mockVersionConfig,
  });

  final List<DeviceDirectoryItem> items;
  final bool shouldThrow;
  final DeviceData? mockDevice;
  final List<ScheduleItem> mockSchedules;
  final List<HistoryItem> mockHistory;
  final DeviceDirectoryItem? mockDirectoryItem;

  @override
  Future<List<DeviceDirectoryItem>> getDeviceDirectory() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return items;
  }

  @override
  Future<DeviceDirectoryItem?> getDeviceDirectoryItem(String id) async {
    return mockDirectoryItem ?? (items.isNotEmpty ? items.first : null);
  }

  @override
  Stream<DeviceData?> watchDevice(String uid) => Stream.value(mockDevice);

  @override
  Stream<List<ScheduleItem>> watchSchedules(String uid) =>
      Stream.value(mockSchedules);

  @override
  Stream<List<HistoryItem>> watchHistory(String uid, {int limit = 50}) =>
      Stream.value(mockHistory);

  final List<ScheduleItem> addedSchedules = [];
  final List<ScheduleItem> updatedSchedules = [];
  final List<String> deletedScheduleIds = [];
  final Map<String, bool> toggledSchedules = {};

  @override
  Future<String> addSchedule(
    String uid, {
    required String time,
    required int level,
    bool enabled = true,
  }) async {
    final item = ScheduleItem(
      id: 'sched_${addedSchedules.length + 1}',
      time: time,
      level: level,
      enabled: enabled,
    );
    addedSchedules.add(item);
    return item.id;
  }

  @override
  Future<void> updateSchedule(
    String uid, {
    required String id,
    required String time,
    required int level,
    required bool enabled,
  }) async {
    updatedSchedules.add(
      ScheduleItem(id: id, time: time, level: level, enabled: enabled),
    );
  }

  @override
  Future<void> toggleSchedule(
    String uid, {
    required String id,
    required bool enabled,
  }) async {
    toggledSchedules[id] = enabled;
  }

  @override
  Future<void> deleteSchedule(String uid, String id) async {
    deletedScheduleIds.add(id);
  }

  final List<String> deletedHistoryIds = [];

  @override
  Future<void> deleteHistoryItem(String uid, String id) async {
    deletedHistoryIds.add(id);
  }

  @override
  Future<String> sendFeedCommand(String uid, int level) async => 'cmd_123';

  final List<String> resetCommands = [];
  final List<String> shutdownCommands = [];
  final Map<String, Map<String, double>> calibrationUpdates = {};

  @override
  Future<String> sendResetCommand(String uid) async {
    resetCommands.add(uid);
    return 'cmd_reset_${resetCommands.length}';
  }

  @override
  Future<String> sendShutdownCommand(String uid) async {
    shutdownCommands.add(uid);
    return 'cmd_shutdown_${shutdownCommands.length}';
  }

  @override
  Future<void> updateCalibration(
    String uid,
    Map<String, double> calibration,
  ) async {
    calibrationUpdates[uid] = Map.from(calibration);
  }

  AppVersionConfig? mockVersionConfig;
  bool shouldThrowVersionCheck = false;

  @override
  Future<AppVersionConfig?> checkAppVersion() async {
    if (shouldThrowVersionCheck) {
      throw Exception('Network error');
    }
    return mockVersionConfig;
  }

  @override
  Stream<DeviceCommand?> watchCommand(String uid, String commandId) =>
      Stream.value(
        DeviceCommand(
          id: commandId,
          type: 'feed',
          level: 1,
          status: 'done',
          createdAt: DateTime.now(),
        ),
      );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('image_gallery_saver_plus'),
          (MethodCall methodCall) async => {
            'isSuccess': true,
            'filePath': 'mock_path',
          },
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/share'),
          (MethodCall methodCall) async => 'success',
        );
  });

  testWidgets('SplashPage menampilkan branding MyFish dan loading', (
    tester,
  ) async {
    final fakeAuth = FakeAuthRepository(initialOnboardingCompleted: false);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: {
          '/onboarding': (_) => const Scaffold(body: Text('Onboarding')),
        },
        home: SplashPage(authRepository: fakeAuth),
      ),
    );

    expect(find.text('MyFish'), findsOneWidget);
    expect(
      find.text('Monitoring & Kontrol Pakan Ikan Otomatis'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('OnboardingPage memiliki 3 slide dan tombol Lanjut / Lewati', (
    tester,
  ) async {
    final fakeAuth = FakeAuthRepository(initialOnboardingCompleted: false);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: {'/login': (_) => const Scaffold(body: Text('Halaman Masuk'))},
        home: OnboardingPage(authRepository: fakeAuth),
      ),
    );

    expect(find.text('Pantau Status Alat'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // Geser ke slide 2
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Atur Jadwal Otomatis'), findsOneWidget);

    // Geser ke slide 3
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Pakan Lengkap'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);

    // Ketuk Mulai -> selesai onboarding dan pindah ke /login
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();
    expect(fakeAuth.initialOnboardingCompleted, true);
    expect(find.text('Halaman Masuk'), findsOneWidget);
  });

  testWidgets(
    'LoginPage menampilkan state kosong ketika device_directory kosong',
    (tester) async {
      final fakeAuth = FakeAuthRepository();
      final fakeDevice = FakeDeviceRepository(items: []);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: LoginPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Belum ada akun alat'), findsOneWidget);
    },
  );

  testWidgets('LoginPage menampilkan state error jika gagal mengambil akun', (
    tester,
  ) async {
    final fakeAuth = FakeAuthRepository();
    final fakeDevice = FakeDeviceRepository(shouldThrow: true);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LoginPage(authRepository: fakeAuth, deviceRepository: fakeDevice),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat akun'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets(
    'LoginPage menampilkan daftar akun dan memvalidasi password salah',
    (tester) async {
      final fakeAuth = FakeAuthRepository(
        mockSignInError: 'Password salah atau akun tidak sesuai',
      );
      final fakeDevice = FakeDeviceRepository(
        items: const [
          DeviceDirectoryItem(
            id: 'esp32_01',
            name: 'Akuarium Utama',
            email: 'akuarium@myfish.com',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: LoginPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi akun tampil
      expect(find.text('Akuarium Utama'), findsOneWidget);
      expect(find.text('akuarium@myfish.com'), findsOneWidget);

      // Coba submit password
      await tester.enterText(find.byType(TextField), 'wrongpassword');
      await tester.tap(find.widgetWithText(AppButton, 'Masuk'));
      await tester.pumpAndSettle();

      // Verifikasi error ditampilkan
      expect(
        find.text('Password salah atau akun tidak sesuai'),
        findsOneWidget,
      );
    },
  );

  testWidgets('LoginPage berhasil masuk dan menuju beranda', (tester) async {
    final fakeAuth = FakeAuthRepository(mockSignInError: null);
    final fakeDevice = FakeDeviceRepository(
      items: const [
        DeviceDirectoryItem(
          id: 'esp32_01',
          name: 'Akuarium Utama',
          email: 'akuarium@myfish.com',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        initialRoute: '/login',
        routes: {
          '/login': (_) =>
              LoginPage(authRepository: fakeAuth, deviceRepository: fakeDevice),
          '/': (_) => const Scaffold(body: Text('Halaman Beranda')),
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'validpassword');
    await tester.tap(find.widgetWithText(AppButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Halaman Beranda'), findsOneWidget);
  });

  testWidgets(
    'PrivacyPolicyPage menampilkan informasi privasi & tombol kembali',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const PrivacyPolicyPage()),
      );

      expect(find.text('Kebijakan Privasi'), findsOneWidget);
      expect(find.text('1. Pengumpulan Data'), findsOneWidget);
      expect(find.text('3. Keamanan Akun & Perangkat'), findsOneWidget);
    },
  );

  testWidgets(
    'DeviceStatusCard menampilkan Terhubung saat online dan Terputus saat offline',
    (tester) async {
      final now = DateTime.now();

      // Uji status online (lastSeen baru saja)
      final onlineDevice = DeviceData(
        uid: 'dev1',
        status: 'online',
        lastSeen: now.subtract(const Duration(seconds: 10)),
        fwVersion: '1.0.0',
        calibration: const {},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DeviceStatusCard(
              device: onlineDevice,
              deviceName: 'Akuarium Utama',
            ),
          ),
        ),
      );

      expect(find.text('Terhubung'), findsWidgets);
      expect(find.text('Akuarium Utama'), findsOneWidget);

      // Uji status offline (lastSeen > 90 detik)
      final offlineDevice = DeviceData(
        uid: 'dev1',
        status: 'offline',
        lastSeen: now.subtract(const Duration(minutes: 5)),
        fwVersion: '1.0.0',
        calibration: const {},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DeviceStatusCard(
              device: offlineDevice,
              deviceName: 'Akuarium Utama',
            ),
          ),
        ),
      );

      expect(find.text('Terputus'), findsWidgets);
      expect(find.textContaining('Terakhir terhubung:'), findsOneWidget);
    },
  );

  testWidgets(
    'FeedingChart menampilkan grafik 7 hari dan keterangan ringkasan',
    (tester) async {
      final refDate = DateTime(2026, 10, 30, 12, 0);
      final history = [
        HistoryItem(
          id: 'h1',
          timestamp: refDate,
          method: 'manual',
          level: 2,
          durationSec: 2.0,
          expireAt: null,
        ),
        HistoryItem(
          id: 'h2',
          timestamp: refDate.subtract(const Duration(days: 1)),
          method: 'auto',
          level: 1,
          durationSec: 1.0,
          expireAt: null,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: FeedingChart(history: history, referenceDate: refDate),
          ),
        ),
      );

      expect(find.text('Grafik Pakan 7 Hari'), findsOneWidget);
      expect(find.text('Total: 2 kali'), findsOneWidget);
    },
  );

  testWidgets(
    'TodaySchedulesSection menampilkan maks 3 jadwal dan badge jumlah jadwal',
    (tester) async {
      final schedules = [
        const ScheduleItem(id: 's1', time: '07:00', level: 1, enabled: true),
        const ScheduleItem(id: 's2', time: '12:00', level: 2, enabled: true),
        const ScheduleItem(id: 's3', time: '18:00', level: 3, enabled: false),
        const ScheduleItem(id: 's4', time: '21:00', level: 1, enabled: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodaySchedulesSection(
              schedules: schedules,
            ),
          ),
        ),
      );

      expect(find.text('Jadwal Hari Ini'), findsOneWidget);
      expect(find.text('4 Jadwal'), findsOneWidget);
      expect(find.text('07:00'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('21:00'), findsNothing); // Maksimal 3 jadwal
    },
  );

  testWidgets(
    'HomePage menampilkan komponen lengkap dan tombol pakan manual nonaktif saat offline',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final offlineDevice = DeviceData(
        uid: 'dev123',
        status: 'offline',
        lastSeen: now.subtract(const Duration(minutes: 5)),
        fwVersion: '1.0.0',
        calibration: const {},
      );

      final fakeAuth = FakeAuthRepository();
      final fakeDevice = FakeDeviceRepository(
        mockDevice: offlineDevice,
        mockDirectoryItem: const DeviceDirectoryItem(
          id: 'dev123',
          name: 'Akuarium Cerdas',
          email: 'akuarium@myfish.com',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HomePage(
            uid: 'dev123',
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header & nama
      expect(find.text('Akuarium Cerdas'), findsWidgets);
      // Kartu status
      expect(find.text('Terputus'), findsWidgets);
      // Tombol Beri Pakan Manual (Alat Offline)
      expect(find.text('Beri Pakan Manual (Alat Offline)'), findsOneWidget);
      expect(
        find.text('Pakan manual dinonaktifkan saat alat offline.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('HomePage saat online dapat membuka bottom sheet pakan manual', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final onlineDevice = DeviceData(
      uid: 'dev123',
      status: 'online',
      lastSeen: now.subtract(const Duration(seconds: 15)),
      fwVersion: '1.0.0',
      calibration: const {},
    );

    final fakeAuth = FakeAuthRepository();
    final fakeDevice = FakeDeviceRepository(
      mockDevice: onlineDevice,
      mockDirectoryItem: const DeviceDirectoryItem(
        id: 'dev123',
        name: 'Akuarium Cerdas',
        email: 'akuarium@myfish.com',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomePage(
          uid: 'dev123',
          authRepository: fakeAuth,
          deviceRepository: fakeDevice,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Pastikan tombol aktif
    final feedBtn = find.widgetWithText(AppButton, 'Beri Pakan Manual');
    expect(feedBtn, findsOneWidget);

    // Ketuk tombol Beri Pakan Manual
    await tester.tap(feedBtn);
    await tester.pumpAndSettle();

    // Verifikasi bottom sheet terbuka
    expect(find.text('Beri Pakan Manual'), findsWidgets);
    expect(find.text('PILIH TAKARAN DOSIS'), findsOneWidget);
    expect(find.text('Geser untuk pakan (Level 1)'), findsOneWidget);
  });

  testWidgets('ScheduleCard menampilkan jam, level, toggle, dan aksi hapus', (
    tester,
  ) async {
    var toggled = false;
    var deleted = false;
    var tapped = false;

    const item = ScheduleItem(id: 's1', time: '08:30', level: 3, enabled: true);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ScheduleCard(
            item: item,
            onTap: () => tapped = true,
            onToggle: (v) => toggled = v,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('Aktif setiap hari'), findsOneWidget);

    // Ketuk selain tombol -> tidak terjadi apa-apa
    await tester.tap(find.text('08:30'));
    expect(tapped, false);

    // Ketuk tombol ubah jadwal
    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(tapped, true);

    // Toggle switch
    await tester.tap(find.byType(Switch));
    expect(toggled, false);

    // Hapus
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    expect(deleted, true);
  });

  testWidgets('ScheduleFormSheet memvalidasi jam ganda', (tester) async {
    final existing = [
      const ScheduleItem(id: 's1', time: '07:00', level: 1, enabled: true),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ScheduleFormSheet.show(
                context,
                existingSchedules: existing,
                onSave: (_, _) async {},
              ),
              child: const Text('Buka Form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Form'));
    await tester.pumpAndSettle();

    // Default time adalah 07:00 yang bentrok dengan s1
    expect(find.text('07:00'), findsOneWidget);

    // Tekan Simpan
    await tester.tap(find.text('Simpan Jadwal'));
    await tester.pumpAndSettle();

    // Validasi jam ganda muncul
    expect(
      find.text('Jam sudah dipakai. Pilih jam yang berbeda.'),
      findsOneWidget,
    );
  });

  testWidgets('SchedulePage menampilkan state kosong dan daftar jadwal', (
    tester,
  ) async {
    final fakeAuth = FakeAuthRepository();
    final fakeDevice = FakeDeviceRepository(
      mockSchedules: const [
        ScheduleItem(id: 's1', time: '07:00', level: 1, enabled: true),
        ScheduleItem(id: 's2', time: '17:00', level: 2, enabled: true),
      ],
      mockDevice: DeviceData(
        uid: 'dev123',
        status: 'offline',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
        fwVersion: '1.0.0',
        calibration: const {},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SchedulePage(
          uid: 'dev123',
          authRepository: fakeAuth,
          deviceRepository: fakeDevice,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Judul & tombol + Tambah Jadwal
    expect(find.text('Jadwal Pakan Harian'), findsOneWidget);
    expect(find.text('Tambah Jadwal'), findsOneWidget);

    // Banner offline tampil karena lastSeen > 90 dtk
    expect(
      find.text('Alat offline. Perubahan akan tersinkron saat online.'),
      findsOneWidget,
    );

    // Daftar jadwal
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('17:00'), findsOneWidget);

    // Test toggle switch
    await tester.tap(find.byType(Switch).first);
    expect(fakeDevice.toggledSchedules['s1'], false);
  });

  testWidgets('showDeleteScheduleDialog dapat dikonfirmasi dan dibatalkan', (
    tester,
  ) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                dialogResult = await showDeleteScheduleDialog(
                  context,
                  time: '07:00',
                );
              },
              child: const Text('Buka Hapus'),
            ),
          ),
        ),
      ),
    );

    // Buka dan batalkan
    await tester.tap(find.text('Buka Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus Jadwal?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(dialogResult, false);

    // Buka dan konfirmasi
    await tester.tap(find.text('Buka Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(dialogResult, true);
  });

  testWidgets('HistoryCard menampilkan jam, metode, dosis, dan aksi hapus', (
    tester,
  ) async {
    var deleted = false;
    final item = HistoryItem(
      id: 'h1',
      timestamp: DateTime(2026, 10, 30, 14, 30),
      method: 'auto',
      level: 2,
      durationSec: 2.0,
      expireAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HistoryCard(
            item: item,
            canDelete: true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('14:30'), findsOneWidget);
    expect(find.text('Otomatis'), findsOneWidget);
    expect(find.text('Lvl 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    expect(deleted, true);
  });

  testWidgets('HistoryPage menampilkan state kosong dan catatan TTL 30 hari', (
    tester,
  ) async {
    final fakeAuth = FakeAuthRepository();
    final fakeDevice = FakeDeviceRepository(mockHistory: const []);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HistoryPage(
          uid: 'dev123',
          authRepository: fakeAuth,
          deviceRepository: fakeDevice,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Riwayat Pakan'), findsOneWidget);
    expect(
      find.text('Riwayat otomatis terhapus setelah 30 hari'),
      findsOneWidget,
    );
    expect(find.text('Belum ada riwayat pakan'), findsOneWidget);
  });

  testWidgets(
    'HistoryPage menampilkan daftar dikelompokkan dan menonaktifkan hapus saat offline',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final todayItem = HistoryItem(
        id: 'h1',
        timestamp: now,
        method: 'manual',
        level: 3,
        durationSec: 3.0,
        expireAt: null,
      );
      final yesterdayItem = HistoryItem(
        id: 'h2',
        timestamp: now.subtract(const Duration(days: 1)),
        method: 'auto',
        level: 1,
        durationSec: 1.0,
        expireAt: null,
      );

      final fakeAuth = FakeAuthRepository();
      final fakeDevice = FakeDeviceRepository(
        mockHistory: [todayItem, yesterdayItem],
        mockDevice: DeviceData(
          uid: 'dev123',
          status: 'offline',
          lastSeen: now.subtract(const Duration(minutes: 5)),
          fwVersion: '1.0.0',
          calibration: const {},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HistoryPage(
            uid: 'dev123',
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Banner offline tampil
      expect(
        find.text(
          'Alat offline. Menampilkan data tersimpan. Hapus dinonaktifkan.',
        ),
        findsOneWidget,
      );

      // Header tanggal pengelompokan
      expect(find.textContaining('Hari Ini'), findsOneWidget);
      expect(find.textContaining('Kemarin'), findsOneWidget);

      // Items
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Otomatis'), findsOneWidget);
      expect(find.text('Lvl 3'), findsOneWidget);
      expect(find.text('Lvl 1'), findsOneWidget);

      // Tombol hapus disabled (onPressed null)
      final deleteButtons = tester.widgetList<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_outline_rounded),
      );
      for (final btn in deleteButtons) {
        expect(btn.onPressed, isNull);
      }
    },
  );

  testWidgets('DeleteHistorySheet menampilkan konfirmasi SlideConfirm', (
    tester,
  ) async {
    var deleted = false;
    final item = HistoryItem(
      id: 'h1',
      timestamp: DateTime(2026, 10, 30, 10, 15),
      method: 'manual',
      level: 2,
      durationSec: 2.0,
      expireAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeleteHistorySheet.show(
                context,
                item: item,
                onDelete: () async => deleted = true,
              ),
              child: const Text('Buka Konfirmasi Hapus'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Konfirmasi Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus Riwayat Pakan?'), findsOneWidget);
    expect(find.text('Geser untuk hapus riwayat'), findsOneWidget);

    // Uji trigger hapus via semantics action SlideConfirm
    tester.semantics.tap(find.semantics.byLabel('Geser untuk hapus riwayat'));
    await tester.pumpAndSettle();

    expect(deleted, true);
  });

  // ==========================================
  // FASE 5: PENGATURAN, KONTROL ESP32, KALIBRASI
  // ==========================================

  testWidgets(
    'SettingsPage menampilkan profil alat, menu pengaturan, dan slide keluar',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeAuthRepository();
      final fakeDevice = FakeDeviceRepository(
        mockDevice: DeviceData(
          uid: 'esp32_user_1',
          status: 'online',
          lastSeen: DateTime.now(),
          fwVersion: '1.0.0',
          calibration: const {},
        ),
      );

      var navigatedToControl = false;
      var navigatedToCalibration = false;
      var navigatedToLogin = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          routes: {
            '/esp32-control': (_) {
              navigatedToControl = true;
              return const Scaffold(body: Text('Page Kontrol ESP32'));
            },
            '/calibration': (_) {
              navigatedToCalibration = true;
              return const Scaffold(body: Text('Page Kalibrasi'));
            },
            '/login': (_) {
              navigatedToLogin = true;
              return const Scaffold(body: Text('Page Login'));
            },
          },
          home: SettingsPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
            email: 'kolam1@myfish.id',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('kolam1@myfish.id'), findsOneWidget);
      expect(find.text('ESP32 MyFish v1.0.0'), findsOneWidget);
      expect(find.text('Terhubung'), findsOneWidget);
      expect(find.text('Kontrol ESP32'), findsOneWidget);
      expect(find.text('Kalibrasi Takaran'), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('Kebijakan Privasi'), findsOneWidget);

      // Navigasi ke Kontrol ESP32
      await tester.tap(find.text('Kontrol ESP32'));
      await tester.pumpAndSettle();
      expect(navigatedToControl, true);

      // Pop kembali
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Navigasi ke Kalibrasi Takaran
      await tester.tap(find.text('Kalibrasi Takaran'));
      await tester.pumpAndSettle();
      expect(navigatedToCalibration, true);

      navigator.pop();
      await tester.pumpAndSettle();

      // Tombol Keluar Akun -> Dialog konfirmasi ("Keluar" di kiri, "Batal" di kanan)
      final logoutBtn = find.widgetWithText(AppButton, 'Keluar Akun');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Keluar
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(fakeAuth.didSignOut, true);
      expect(navigatedToLogin, true);
    },
  );

  testWidgets(
    'Esp32ControlPage menonaktifkan aksi saat offline dan tampilkan banner',
    (tester) async {
      final fakeAuth = FakeAuthRepository();
      final offlineDevice = DeviceData(
        uid: 'esp32_user_1',
        status: 'offline',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      final fakeDevice = FakeDeviceRepository(mockDevice: offlineDevice);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Esp32ControlPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Alat sedang offline. Aksi kontrol ESP32 dinonaktifkan.'),
        findsOneWidget,
      );

      // Tapping on cards should not open dialog
      await tester.tap(find.text('Reset Ulang ESP32'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Reset ESP32'), findsNothing);

      await tester.tap(find.text('Matikan ESP32'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Matikan ESP32'), findsNothing);
    },
  );

  testWidgets(
    'Esp32ControlPage alur Reset: verifikasi password -> slide confirm -> kirim command',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeAuthRepository();
      final onlineDevice = DeviceData(
        uid: 'esp32_user_1',
        status: 'online',
        lastSeen: DateTime.now(),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      final fakeDevice = FakeDeviceRepository(mockDevice: onlineDevice);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Esp32ControlPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Reset
      await tester.tap(find.text('Reset Ulang ESP32'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Reset ESP32'), findsOneWidget);

      // Coba masukkan password salah
      fakeAuth.mockReauthError = 'Password salah';
      await tester.enterText(find.byType(TextField), 'wrongpass');
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Password salah'), findsOneWidget);
      expect(find.text('Reset Ulang ESP32'), findsWidgets); // Masih di dialog

      // Masukkan password benar
      fakeAuth.mockReauthError = null;
      await tester.enterText(find.byType(TextField), 'correctpass');
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Dialog tertutup, sheet SlideConfirm terbuka
      expect(find.text('Geser untuk reset ESP32'), findsOneWidget);

      // Geser konfirmasi
      tester.semantics.tap(find.semantics.byLabel('Geser untuk reset ESP32'));
      await tester.pumpAndSettle();

      // Command terkirim
      expect(fakeDevice.resetCommands, contains('esp32_user_1'));
      expect(find.text('Perintah reset terkirim'), findsOneWidget);
    },
  );

  testWidgets(
    'Esp32ControlPage alur Shutdown: password -> slide confirm -> kirim command',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeAuthRepository();
      final onlineDevice = DeviceData(
        uid: 'esp32_user_1',
        status: 'online',
        lastSeen: DateTime.now(),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      final fakeDevice = FakeDeviceRepository(mockDevice: onlineDevice);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Esp32ControlPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Matikan ESP32
      await tester.tap(find.text('Matikan ESP32'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Matikan ESP32'), findsOneWidget);

      // Masukkan password benar
      fakeAuth.mockReauthError = null;
      await tester.enterText(find.byType(TextField), 'secretpass');
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Geser untuk matikan ESP32'), findsOneWidget);

      // Geser konfirmasi
      tester.semantics.tap(find.semantics.byLabel('Geser untuk matikan ESP32'));
      await tester.pumpAndSettle();

      expect(fakeDevice.shutdownCommands, contains('esp32_user_1'));
      expect(find.text('Perintah matikan terkirim'), findsOneWidget);
    },
  );

  testWidgets(
    'CalibrationPage menonaktifkan aksi saat offline dan tampilkan banner',
    (tester) async {
      final fakeAuth = FakeAuthRepository();
      final offlineDevice = DeviceData(
        uid: 'esp32_user_1',
        status: 'offline',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        fwVersion: '1.0.0',
        calibration: const {},
      );
      final fakeDevice = FakeDeviceRepository(mockDevice: offlineDevice);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CalibrationPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Alat sedang offline. Kalibrasi dinonaktifkan.'),
        findsOneWidget,
      );

      final saveButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Alat Offline'),
      );
      expect(saveButton.onPressed, isNull);
    },
  );

  testWidgets(
    'CalibrationPage stepper, validasi urutan bertambah, password -> slide simpan',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeAuthRepository();
      final onlineDevice = DeviceData(
        uid: 'esp32_user_1',
        status: 'online',
        lastSeen: DateTime.now(),
        fwVersion: '1.0.0',
        calibration: {'l1': 1.0, 'l2': 2.0, 'l3': 3.0, 'l4': 4.0, 'l5': 5.0},
      );
      final fakeDevice = FakeDeviceRepository(mockDevice: onlineDevice);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CalibrationPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Cek nilai awal terload
      expect(find.text('1.0 dtk'), findsOneWidget);
      expect(find.text('2.0 dtk'), findsOneWidget);
      expect(find.text('3.0 dtk'), findsOneWidget);
      expect(find.text('4.0 dtk'), findsOneWidget);
      expect(find.text('5.0 dtk'), findsOneWidget);

      // Simpan dinonaktifkan karena belum ada perubahan
      var saveButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Simpan Kalibrasi'),
      );
      expect(saveButton.onPressed, isNull);

      // Naikkan Level 5 dari 5.0 dtk ke 5.2 dtk (2 kali tap tombol +)
      final addButtons = find.widgetWithIcon(
        IconButton,
        Icons.add_circle_outline_rounded,
      );
      // Tombol kelima adalah level 5
      await tester.tap(addButtons.at(4));
      await tester.pumpAndSettle();
      await tester.tap(addButtons.at(4));
      await tester.pumpAndSettle();

      expect(find.text('5.2 dtk'), findsOneWidget);

      // Tombol Simpan sekarang aktif
      saveButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Simpan Kalibrasi'),
      );
      expect(saveButton.onPressed, isNotNull);

      // Uji validasi tidak bertambah: naikkan Level 1 berulang kali sampai >= Level 2 (2.0 dtk)
      for (var i = 0; i < 11; i++) {
        await tester.tap(addButtons.at(0));
        await tester.pumpAndSettle();
      }
      // Sekarang Level 1 = 2.1 dtk, Level 2 = 2.0 dtk -> melanggar syarat urutan bertambah
      expect(
        find.text(
          'Durasi takaran harus bertambah naik di setiap level (Level 1 < Level 2 < Level 3 < Level 4 < Level 5).',
        ),
        findsOneWidget,
      );
      saveButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Simpan Kalibrasi'),
      );
      expect(saveButton.onPressed, isNull);

      // Turunkan kembali Level 1 ke 1.0 dtk
      final removeButtons = find.widgetWithIcon(
        IconButton,
        Icons.remove_circle_outline_rounded,
      );
      for (var i = 0; i < 11; i++) {
        await tester.tap(removeButtons.at(0));
        await tester.pumpAndSettle();
      }
      expect(find.text('1.0 dtk'), findsOneWidget);

      // Tombol Simpan kembali aktif
      saveButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Simpan Kalibrasi'),
      );
      expect(saveButton.onPressed, isNotNull);

      // Tap Simpan Kalibrasi
      await tester.tap(find.widgetWithText(AppButton, 'Simpan Kalibrasi'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Kalibrasi'), findsOneWidget);

      // Masukkan password
      fakeAuth.mockReauthError = null;
      await tester.enterText(find.byType(TextField), 'myfishpassword');
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // Sheet SlideConfirm
      expect(find.text('Geser untuk simpan kalibrasi'), findsOneWidget);

      // Geser konfirmasi
      tester.semantics.tap(
        find.semantics.byLabel('Geser untuk simpan kalibrasi'),
      );
      await tester.pumpAndSettle();

      // Verifikasi updateCalibration dipanggil dengan level 5 = 5.2
      expect(fakeDevice.calibrationUpdates.containsKey('esp32_user_1'), true);
      final updated = fakeDevice.calibrationUpdates['esp32_user_1']!;
      expect(updated['l1'], 1.0);
      expect(updated['l5'], 5.2);
      expect(find.text('Kalibrasi tersimpan'), findsOneWidget);
    },
  );

  // ==========================================
  // FASE 6: HALAMAN INFO & PEMBARUAN
  // ==========================================

  test(
    'AppVersionConfig.isNewer membandingkan versi semantik secara benar',
    () {
      expect(AppVersionConfig.isNewer('1.0.0', '1.1.0'), isTrue);
      expect(AppVersionConfig.isNewer('1.0.0', '1.0.1'), isTrue);
      expect(AppVersionConfig.isNewer('1.9.5', '2.0.0'), isTrue);
      expect(AppVersionConfig.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(AppVersionConfig.isNewer('1.1.0', '1.0.0'), isFalse);
    },
  );

  testWidgets(
    'AboutAppPage menampilkan deskripsi, fitur, dan dapat menyalin link unduh',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AboutAppPage()),
      );

      expect(find.text('MyFish'), findsOneWidget);
      expect(find.text('Versi ${AppConstants.appVersion}'), findsOneWidget);
      expect(find.text('Fitur Unggulan'), findsOneWidget);
      expect(find.text('Monitoring Realtime'), findsOneWidget);
      expect(find.text('Pemberian Pakan Manual'), findsOneWidget);
      expect(find.text('Penjadwalan Otomatis'), findsOneWidget);
      expect(find.text('Riwayat & Grafik 7 Hari'), findsOneWidget);
      expect(find.text('Kalibrasi Takaran Presisi'), findsOneWidget);
      expect(find.text(AppConstants.downloadUrl), findsOneWidget);

      // Scroll dan tap Salin Tautan
      final copyBtn = find.widgetWithText(AppButton, 'Salin Tautan');
      await tester.ensureVisible(copyBtn);
      await tester.tap(copyBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Tautan unduh berhasil disalin'), findsOneWidget);
    },
  );

  testWidgets(
    'AboutDeveloperPage menampilkan profil dan menyalin email & WhatsApp',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AboutDeveloperPage()),
      );

      expect(find.text(AppConstants.developerName), findsOneWidget);
      expect(find.text('syauqiakmal137@gmail.com'), findsOneWidget);
      expect(find.text('081298628236'), findsOneWidget);

      // Scroll dan tap Salin Email
      final copyEmailBtn = find.widgetWithText(AppButton, 'Salin Email');
      await tester.ensureVisible(copyEmailBtn);
      await tester.tap(copyEmailBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Email berhasil disalin ke papan klip'), findsOneWidget);

      // Scroll dan tap Salin Nomor
      final copyPhoneBtn = find.widgetWithText(AppButton, 'Salin Nomor');
      await tester.ensureVisible(copyPhoneBtn);
      await tester.tap(copyPhoneBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Nomor WhatsApp berhasil disalin ke papan klip'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SupportDeveloperPage menampilkan QRIS dan tombol aksi simpan / bagikan',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      var didSave = false;
      var didShare = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SupportDeveloperPage(
            onSaveQris: () async => didSave = true,
            onShareQris: () async => didShare = true,
          ),
        ),
      );

      expect(find.text('Apresiasi & Donasi'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Kode QRIS pengembang',
        ),
        findsOneWidget,
      );

      final saveQrisBtn = find.widgetWithText(
        AppButton,
        'Simpan QRIS ke Galeri',
      );
      final shareQrisBtn = find.widgetWithText(AppButton, 'Bagikan QRIS');

      expect(saveQrisBtn, findsOneWidget);
      expect(shareQrisBtn, findsOneWidget);

      // Tap Simpan QRIS
      await tester.ensureVisible(saveQrisBtn);
      await tester.tap(saveQrisBtn);
      await tester.pumpAndSettle();
      expect(didSave, true);

      // Tap Bagikan QRIS
      await tester.ensureVisible(shareQrisBtn);
      await tester.tap(shareQrisBtn);
      await tester.pumpAndSettle();
      expect(didShare, true);
    },
  );

  testWidgets(
    'SettingsPage navigasi ke halaman info dan alur Periksa Pembaruan',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeAuthRepository();
      final fakeDevice = FakeDeviceRepository(
        mockDevice: const DeviceData(
          uid: 'esp32_user_1',
          status: 'online',
          lastSeen: null,
          fwVersion: '1.0.0',
          calibration: {},
        ),
        mockVersionConfig: const AppVersionConfig(
          latest: '1.0.0',
          downloadUrl: AppConstants.downloadUrl,
        ),
      );

      var visitedAboutApp = false;
      var visitedAboutDev = false;
      var visitedSupportDev = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          routes: {
            '/about-app': (_) {
              visitedAboutApp = true;
              return const Scaffold(body: Text('About App View'));
            },
            '/about-developer': (_) {
              visitedAboutDev = true;
              return const Scaffold(body: Text('About Dev View'));
            },
            '/support-developer': (_) {
              visitedSupportDev = true;
              return const Scaffold(body: Text('Support Dev View'));
            },
            '/privacy-policy': (_) =>
                const Scaffold(body: Text('Privacy View')),
          },
          home: SettingsPage(
            authRepository: fakeAuth,
            deviceRepository: fakeDevice,
            uid: 'esp32_user_1',
            email: 'test@myfish.id',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigasi Tentang Aplikasi
      await tester.tap(find.text('Tentang Aplikasi'));
      await tester.pumpAndSettle();
      expect(visitedAboutApp, isTrue);

      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // Navigasi Tentang Pengembang
      await tester.tap(find.text('Tentang Pengembang'));
      await tester.pumpAndSettle();
      expect(visitedAboutDev, isTrue);

      nav.pop();
      await tester.pumpAndSettle();

      // Navigasi Dukung Pengembang
      await tester.tap(find.text('Dukung Pengembang'));
      await tester.pumpAndSettle();
      expect(visitedSupportDev, isTrue);

      nav.pop();
      await tester.pumpAndSettle();

      // Periksa Pembaruan (versi sama -> 'Sudah versi terbaru')
      final checkBtn = find.widgetWithText(AppButton, 'Periksa Pembaruan');
      expect(checkBtn, findsOneWidget);
      await tester.ensureVisible(checkBtn);
      await tester.tap(checkBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Sudah versi terbaru'), findsOneWidget);

      // Tombol sekarang dalam kondisi cooldown
      expect(find.textContaining('Periksa Pembaruan ('), findsOneWidget);

      // Cooldown tombol disabled
      final cooldownBtn = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Periksa Pembaruan (60s)'),
      );
      expect(cooldownBtn.onPressed, isNull);
    },
  );

  testWidgets('SettingsPage menampilkan dialog jika ada versi pembaruan baru', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final fakeAuth = FakeAuthRepository();
    final fakeDevice = FakeDeviceRepository(
      mockDevice: const DeviceData(
        uid: 'esp32_user_1',
        status: 'online',
        lastSeen: null,
        fwVersion: '1.0.0',
        calibration: {},
      ),
      mockVersionConfig: const AppVersionConfig(
        latest: '1.2.0',
        downloadUrl: 'https://drive.google.com/test_update',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SettingsPage(
          authRepository: fakeAuth,
          deviceRepository: fakeDevice,
          uid: 'esp32_user_1',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Periksa Pembaruan
    final checkBtn = find.widgetWithText(AppButton, 'Periksa Pembaruan');
    await tester.ensureVisible(checkBtn);
    await tester.tap(checkBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Menampilkan dialog pembaruan tersedia
    expect(find.text('Pembaruan Tersedia!'), findsOneWidget);
    expect(find.textContaining('Versi 1.2.0 telah tersedia'), findsOneWidget);
    expect(find.text('Nanti saja'), findsOneWidget);
    expect(find.text('Perbarui'), findsOneWidget);

    // Tap Nanti saja menutup dialog
    await tester.tap(find.text('Nanti saja'));
    await tester.pumpAndSettle();

    expect(find.text('Pembaruan Tersedia!'), findsNothing);
  });

  testWidgets('AppHeader menampilkan branding MyFish dan ikon dekoratif', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(appBar: AppHeader()),
      ),
    );

    expect(find.text('MyFish'), findsOneWidget);
    expect(find.byIcon(Icons.set_meal_rounded), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
    expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
  });

  testWidgets('RecentHistorySection menampilkan maks 5 riwayat dan state kosong', (
    tester,
  ) async {
    // 1. State kosong
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: RecentHistorySection(history: [])),
      ),
    );

    expect(find.text('Riwayat Pakan Terakhir'), findsOneWidget);
    expect(find.text('Belum ada riwayat pakan'), findsOneWidget);

    // 2. Ada data riwayat (maks 5)
    final now = DateTime.now();
    final items = List.generate(
      7,
      (i) => HistoryItem(
        id: 'h$i',
        timestamp: now.subtract(Duration(hours: i * 2)),
        method: i.isEven ? 'auto' : 'manual',
        level: (i % 5) + 1,
        durationSec: 1.5,
        expireAt: null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: RecentHistorySection(history: items)),
      ),
    );

    expect(find.text('5 Terbaru'), findsOneWidget);
    expect(find.text('Otomatis'), findsWidgets);
    expect(find.text('Manual'), findsWidgets);
  });

  testWidgets('ScheduleCard memiliki tombol ubah jadwal yang dapat diketuk', (
    tester,
  ) async {
    var editTapped = false;
    const item = ScheduleItem(
      id: 's1',
      time: '08:00',
      level: 2,
      enabled: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ScheduleCard(
            item: item,
            onTap: () => editTapped = true,
            onToggle: (_) {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    // Mengetuk teks jam tidak memicu edit (hanya tombol ubah yang memicu)
    await tester.tap(find.text('08:00'));
    expect(editTapped, false);

    // Mengetuk tombol ubah memicu edit
    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(editTapped, true);
  });
}
