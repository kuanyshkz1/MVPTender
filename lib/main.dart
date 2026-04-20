import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_router.dart';
// 1. Добавь импорт нашей модели
import 'data/models/tender_note.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  // 2. РЕГИСТРИРУЕМ АДАПТЕР (ОБЯЗАТЕЛЬНО ДО ОТКРЫТИЯ КОРОБКИ)
  Hive.registerAdapter(TenderNoteAdapter()); 

  await Hive.openBox('tendersBox'); // Старая коробка для кэша интернета
  
  // 3. Открываем НОВУЮ типизированную коробку специально для Избранного/Заметок
  await Hive.openBox<TenderNote>('notesBox'); 

  runApp(const ProviderScope(child: TenderApp()));
}

// ... дальше твой класс TenderApp без изменений