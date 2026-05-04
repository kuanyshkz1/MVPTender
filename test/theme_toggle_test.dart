import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaztender/core/providers/dependencies_providers.dart';
import 'package:qaztender/core/providers/theme_mode_provider.dart';
import 'package:qaztender/domain/entities/tender.dart';
import 'package:qaztender/domain/repositories/tender_repository.dart';
import 'package:qaztender/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTenderRepository implements TenderRepository {
  @override
  Future<List<Tender>> fetchTenders({String searchQuery = ''}) async {
    return [
      Tender(
        number: '123',
        title: 'Тестовый тендер',
        customer: 'Тестовый заказчик',
        bin: '123456789012',
        price: 100000,
        type: 'Товары',
        status: 'Прием заявок',
        endDate: DateTime(2026, 5, 10, 18, 30),
      ),
    ];
  }
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ref.watch(themeModeProvider),
      home: const HomeScreen(),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Переключение темной темы из bottom sheet не вызывает ошибок', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tenderRepositoryProvider.overrideWithValue(_FakeTenderRepository()),
        ],
        child: const _TestApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Темная тема'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
