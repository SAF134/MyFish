import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hasil otentikasi. `null` = sukses; selain itu pesan error UI berbahasa Indonesia.
typedef AuthResult = String?;

/// Akses Firebase Auth dan preferensi sesi. UI tidak memanggil FirebaseAuth langsung.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, SharedPreferences? prefs})
    : _authOverride = auth,
      _prefsOverride = prefs;

  static const String _onboardingKey = 'myfish_has_seen_onboarding';

  final FirebaseAuth? _authOverride;
  final SharedPreferences? _prefsOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Masuk dengan email dan password.
  /// Mengembalikan `null` jika sukses, atau pesan kesalahan berbahasa Indonesia.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return mapAuthError(e.code);
    } catch (_) {
      return 'Terjadi kesalahan saat masuk. Coba lagi.';
    }
  }

  /// Keluar dari akun.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Re-autentikasi pengguna saat ini dengan password (`reauthenticateWithCredential`).
  /// Password tidak pernah disimpan atau di-log.
  Future<AuthResult> reauthenticate(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return 'Sesi berakhir. Silakan masuk kembali.';
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return mapAuthError(e.code);
    } catch (_) {
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  /// Memeriksa apakah pengguna sudah menyelesaikan onboarding.
  Future<bool> isOnboardingCompleted() async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Menandai onboarding telah diselesaikan.
  Future<void> setOnboardingCompleted() async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Memetakan kode error Firebase Auth ke pesan berbahasa Indonesia.
  static String mapAuthError(String code) => switch (code) {
    'wrong-password' ||
    'invalid-credential' ||
    'user-not-found' => 'Password salah atau akun tidak sesuai',
    'invalid-email' => 'Format email tidak valid',
    'network-request-failed' => 'Tidak ada internet',
    'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
    'user-disabled' => 'Akun alat dinonaktifkan',
    _ => 'Terjadi kesalahan. Coba lagi.',
  };
}
