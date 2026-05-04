import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_router.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/constants/app_colors.dart';
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
    final themeMode = ref.watch(themeModeProvider);
    final lightColorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.lightPrimary,
          surface: AppColors.lightSurface,
          surfaceTint: AppColors.white,
        ).copyWith(
          onSurface: AppColors.lightOnSurface,
          onSurfaceVariant: AppColors.lightOnSurfaceVariant,
          surfaceContainerLow: AppColors.lightSurfaceContainerLow,
          surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
          outlineVariant: AppColors.lightOutlineVariant,
          primary: AppColors.lightPrimary,
        );
    final darkColorScheme =
        ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: AppColors.darkPrimary,
          surface: AppColors.darkScaffoldBg,
        ).copyWith(
          onSurface: AppColors.darkOnSurface,
          onSurfaceVariant: AppColors.darkOnSurfaceVariant,
          surface: AppColors.darkScaffoldBg,
          surfaceContainerLow: AppColors.darkSurfaceContainerLow,
          surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
          outlineVariant: AppColors.darkOutlineVariant,
          primary: AppColors.darkPrimary,
        );

    return MaterialApp.router(
      scrollBehavior: const AppScrollBehavior(),
      title: 'QazTender',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: AppColors.lightSurface,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          scrolledUnderElevation: 1,
          iconTheme: const IconThemeData(color: AppColors.lightIconMuted),
          titleTextStyle: const TextStyle(
            color: AppColors.lightOnSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurfaceContainerLow,
          surfaceTintColor: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lightOutlineVariant),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightOutlineVariant,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.lightOutlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.lightOutlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.lightPrimary,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightOnSurface,
          contentTextStyle: const TextStyle(color: AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.1),
          selectedColor: AppColors.lightPrimary.withValues(alpha: 0.16),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          showDragHandle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: AppColors.darkScaffoldBg,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark(useMaterial3: true).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.darkScaffoldBg,
          surfaceTintColor: AppColors.darkScaffoldBg,
          scrolledUnderElevation: 1,
          iconTheme: const IconThemeData(color: AppColors.darkOnSurfaceVariant),
          titleTextStyle: const TextStyle(
            color: AppColors.darkOnSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        cardColor: AppColors.darkSurfaceContainerLow,
        cardTheme: CardThemeData(
          color: AppColors.darkSurfaceContainerLow,
          surfaceTintColor: AppColors.darkSurfaceContainerLow,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkOutlineVariant),
          ),
        ),
        dividerColor: AppColors.darkOutlineVariant,
        dividerTheme: const DividerThemeData(
          color: AppColors.darkOutlineVariant,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkOutlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkOutlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.darkPrimary,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkOnSurface,
          contentTextStyle: const TextStyle(color: AppColors.darkScaffoldBg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkPrimary.withValues(alpha: 0.14),
          selectedColor: AppColors.darkPrimary.withValues(alpha: 0.2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurfaceContainerLow,
          surfaceTintColor: AppColors.darkSurfaceContainerLow,
          showDragHandle: true,
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
