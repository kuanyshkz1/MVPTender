import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth_storage.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  StreamSubscription<User?>? _authSubscription;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _resolveStartRoute,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveStartRoute(FirebaseAuth.instance.currentUser);
    });
  }

  Future<void> _resolveStartRoute(User? user) async {
    if (!mounted || _isNavigating) return;

    final isFirstLaunch = await AuthStorage.isFirstLaunch();
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    context.go(
      user == null ? '/login' : (isFirstLaunch ? '/welcome' : '/home'),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.search_rounded,
                color: colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'QazTender',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 2.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
