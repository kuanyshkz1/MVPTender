import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_router.dart';
import 'data/models/tender_note.dart';

import 'package:google_fonts/google_fonts.dart';

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
      scrollBehavior: const AppScrollBehavior(),
      title: 'QazTender',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Modern nice blue
          surface: const Color(0xFFF8FAFC), // Light gray-blue background
          surfaceTint: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 1,
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppScrollBehavior extends ScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
