import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../domain/entities/user_entity.dart';

// Firebase Auth Service Provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Current User Stream Provider
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges.map((user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  });
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final FirebaseAuthService _authService;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(
          UserEntity(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoURL: user.photoURL,
            createdAt: user.metadata.creationTime,
          ),
        );
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      return _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      return _authService.signIn(email: email, password: password);
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _authService.signOut();
      return null;
    });
    state = result;
    if (result.hasError) {
      throw result.error!;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await _authService.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
    state = AsyncValue.data(_authService.currentUserEntity);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
      final authService = ref.watch(firebaseAuthServiceProvider);
      return AuthNotifier(authService);
    });

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenData((user) => user != null).value ?? false;
});

// Helper provider to get current user
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenData((user) => user).value;
});
