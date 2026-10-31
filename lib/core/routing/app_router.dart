import 'package:flutter/material.dart';

import '../../features/login/login_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/settings/about_app_page.dart';
import '../../features/settings/about_developer_page.dart';
import '../../features/settings/calibration_page.dart';
import '../../features/settings/esp32_control_page.dart';
import '../../features/settings/privacy_policy_page.dart';
import '../../features/settings/support_developer_page.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_page.dart';
import 'app_routes.dart';

/// Router aplikasi berbasis `onGenerateRoute`.
abstract final class AppRouter {
  static const String initialRoute = AppRoutes.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashPage(),
      AppRoutes.onboarding => const OnboardingPage(),
      AppRoutes.login => const LoginPage(),
      AppRoutes.shell => const MainShell(),
      AppRoutes.privacyPolicy => const PrivacyPolicyPage(),
      AppRoutes.esp32Control => const Esp32ControlPage(),
      AppRoutes.calibration => const CalibrationPage(),
      AppRoutes.aboutApp => const AboutAppPage(),
      AppRoutes.aboutDeveloper => const AboutDeveloperPage(),
      AppRoutes.supportDeveloper => const SupportDeveloperPage(),
      _ => const SplashPage(),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
