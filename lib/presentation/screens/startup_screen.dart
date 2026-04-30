import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth_storage.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _resolveStartRoute();
  }

  Future<void> _resolveStartRoute() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();
    final isFirstLaunch = await AuthStorage.isFirstLaunch();

    if (!mounted) return;

    if (!isLoggedIn) {
      context.go('/login');
      return;
    }

    context.go(isFirstLaunch ? '/welcome' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      ),
    );
  }
}
