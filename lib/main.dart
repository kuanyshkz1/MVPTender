import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // 1. ИМПОРТИРУЕМ НАШ НОВЫЙ ЭКРАН

void main() {
  runApp(const TenderApp());
}

class TenderApp extends StatelessWidget {
  const TenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tenders KZ',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      // 2. СТАВИМ ЭКРАН ПРИВЕТСТВИЯ СТАРТОВЫМ
      home: const WelcomeScreen(), 
    );
  }
}