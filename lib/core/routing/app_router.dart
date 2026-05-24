import 'package:go_router/go_router.dart';
import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/auth/presentation/pages/splash_page.dart';
import '../../modules/auth/presentation/pages/unlock_page.dart';
import '../../modules/auth/presentation/pages/pin_setup_page.dart';
import '../../modules/calculators/presentation/pages/calculators_page.dart';
import '../../modules/calculators/presentation/pages/calculator_detail_page.dart';
import '../../modules/ai/presentation/pages/ai_page.dart';
import '../../modules/settings/presentation/pages/settings_page.dart';

final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/unlock',
        name: 'unlock',
        builder: (_, __) => const UnlockPage(),
      ),
      GoRoute(
        path: '/pin-setup',
        name: 'pinSetup',
        builder: (_, __) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/calculators',
        name: 'calculators',
        builder: (_, __) => const CalculatorsPage(),
        routes: [
          GoRoute(
            path: ':calculatorType',
            name: 'calculatorDetail',
            builder: (_, state) => CalculatorDetailPage(
              type: state.pathParameters['calculatorType']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/ai',
        name: 'ai',
        builder: (_, __) => const AiPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),
    ],
  );
}
