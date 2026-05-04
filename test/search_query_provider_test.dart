import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Убедитесь, что путь к вашему файлу с провайдерами указан верно
import 'package:qaztender/providers/providers.dart'; 

void main() {
  // Группа тестов для searchQueryProvider
  group('searchQueryProvider Tests', () {
    
    test('Начальное значение должно быть пустой строкой', () {
      // Создаем контейнер для управления состоянием провайдеров в тестах
      final container = ProviderContainer();
      // Очищаем контейнер после завершения теста
      addTearDown(container.dispose);

      final initialQuery = container.read(searchQueryProvider);
      
      expect(initialQuery, '');
    });

    test('Состояние обновляется корректно при вводе текста', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Обновляем значение (эмулируем ввод пользователя)
      container.read(searchQueryProvider.notifier).state = 'Ремонт дорог';

      // Читаем новое значение и проверяем
      final updatedQuery = container.read(searchQueryProvider);
      expect(updatedQuery, 'Ремонт дорог');
    });
  });
}