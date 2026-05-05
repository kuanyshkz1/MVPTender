import 'package:go_router/go_router.dart';
import '../domain/entities/tender.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/signup_screen.dart';
import '../presentation/screens/startup_screen.dart';
import '../presentation/screens/analytics_screen.dart';
import '../presentation/screens/welcome_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/filter_screen.dart';
import '../presentation/screens/tender_details_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    // Экран приветствия (Onboarding)
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    // Главный экран
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Детали тендера (вложенный маршрут)
        GoRoute(
          path: 'details',
          builder: (context, state) {
            final tender = state.extra as Tender;
            return TenderDetailsScreen(tender: tender);
          },
        ),
      ],
    ),
    // Экран фильтров
    GoRoute(
      path: '/filters',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
  ],
);
