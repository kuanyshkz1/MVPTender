import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/welcome_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/filter_screen.dart';
import '../data/models/tender_model.dart';
import '../presentation/screens/tender_details_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Экран приветствия (Onboarding)
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    // Главный экран
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
      routes: [
        // Детали тендера (вложенный маршрут)
        GoRoute(
          path: 'details',
          builder: (context, state) {
            final tender = state.extra as Tender; // Передаем объект тендера через extra
            return TenderDetails_screen(tender: tender);
          },
        ),
      ],
    ),
    // Экран фильтров
    GoRoute(
      path: '/filters',
      builder: (context, state) => const FilterScreen(),
    ),
  ],
);