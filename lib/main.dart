import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_router.dart';
import 'data/models/tender_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Регистрируем адаптер
  Hive.registerAdapter(TenderNoteAdapter());

  await Hive.openBox('tendersBox');
  await Hive.openBox<TenderNote>('notesBox');

  runApp(const ProviderScope(child: TenderApp()));
}

class TenderApp extends ConsumerWidget {
  const TenderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'QazTender',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}