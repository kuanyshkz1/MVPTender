import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qaztender/presentation/screens/welcome_screen.dart';

void main() {
  setUp(() {
    // Устанавливаем начальные значения для SharedPreferences перед каждым тестом,
    // чтобы нативный канал плагина не выдавал ошибку.
    SharedPreferences.setMockInitialValues({});
  });

  // Вспомогательная функция для создания тестового виджета, обернутого в GoRouter
  Widget createTestWidget() {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen Mock')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen Mock')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('WelcomeScreen изначально отображает первую страницу', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    expect(
      find.text('Все тендеры Казахстана\nв одном кармане'),
      findsOneWidget,
    );
    expect(find.text('Далее'), findsOneWidget);
    expect(find.text('Пропустить'), findsOneWidget);
  });

  testWidgets(
    'WelcomeScreen переходит на следующую страницу при нажатии на "Далее"',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      expect(find.text('Умная фильтрация'), findsOneWidget);
    },
  );

  testWidgets(
    'WelcomeScreen завершает онбординг и переходит на /login при нажатии "Пропустить"',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Пропустить'));
      await tester.pumpAndSettle();

      // Проверяем переход на замоканный экран логина
      expect(find.text('Login Screen Mock'), findsOneWidget);

      // Проверяем, что флаг SharedPreferences был корректно обновлен
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isFirstLaunch'), isFalse);
    },
  );

  testWidgets(
    'WelcomeScreen завершает онбординг и переходит на /login на последней странице',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Переходим на вторую страницу
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      // Переходим на третью (последнюю) страницу
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      expect(find.text('Первые закупки\nуже ждут тебя'), findsOneWidget);
      expect(find.text('Начать поиск'), findsOneWidget);

      // Завершаем онбординг
      await tester.tap(find.text('Начать поиск'));
      await tester.pumpAndSettle();

      // Проверяем переход на замоканный экран логина
      expect(find.text('Login Screen Mock'), findsOneWidget);

      // Проверяем, что флаг SharedPreferences был корректно обновлен
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isFirstLaunch'), isFalse);
    },
  );
}
