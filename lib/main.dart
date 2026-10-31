import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait dikunci (DESIGN.md §9).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Jangan menggagalkan start-up; fitur Firebase akan menampilkan state error.
    debugPrint('Inisialisasi Firebase gagal: ${e.runtimeType}');
    if (kDebugMode) debugPrint('$e');
  }

  runApp(const MyFishApp());
}
