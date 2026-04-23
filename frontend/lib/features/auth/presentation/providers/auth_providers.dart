import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state.dart';
import 'token_storage_service.dart';

// ─── Provider graph ────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final signupUseCaseProvider = Provider<SignupUseCase>(
  (ref) => SignupUseCase(ref.watch(authRepositoryProvider)),
);

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>(
  (ref) => RefreshTokenUseCase(ref.watch(authRepositoryProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);

// ─── Controller ────────────────────────────────────────────────────────────────

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  Timer? _cooldownTimer;

  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  // ── Bootstrap ────────────────────────────────────────────────────────────

  Future<void> _bootstrap() async {
    state = state.copyWith(status: AuthStatus.loading, message: null);
    try {
      final access = await _ref
          .read(tokenStorageProvider)
          .readAccessToken()
          .timeout(const Duration(seconds: 5));

      state = state.copyWith(
        status: (access != null && access.isNotEmpty)
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        message: null,
      );
    } on TimeoutException {
      // Degrade gracefully – let user log in again.
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Startup timed out. Please sign in again.',
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Could not restore session. Please sign in.',
      );
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, message: null);
    try {
      final tokens =
          await _ref.read(loginUseCaseProvider)(email, password);
      await _ref.read(tokenStorageProvider).writeTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: e.toString(),
      );
    }
  }

  // ── Signup ───────────────────────────────────────────────────────────────

  Future<void> signup(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, message: null);
    try {
      await _ref.read(signupUseCaseProvider)(email, password);
      state = state.copyWith(
        status: AuthStatus.verificationPending,
        pendingEmail: email,
        message: 'Verification email sent. Please check your inbox.',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: e.toString(),
      );
    }
  }

  // ── Resend verification ───────────────────────────────────────────────────

  Future<void> resendVerification() async {
    final email = state.pendingEmail;
    if (email == null || state.resendCooldownSec > 0) return;
    try {
      await _ref
          .read(authRepositoryProvider)
          .resendVerificationCode(email: email);
      _startCooldown(30);
      state = state.copyWith(
        status: AuthStatus.verificationPending,
        message: 'Verification email resent.',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: e.toString(),
      );
    }
  }

  // ── Verify email token ────────────────────────────────────────────────────

  Future<bool> verifyEmailToken({
    required String uid,
    required String token,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, message: null);
    try {
      final ok = await _ref
          .read(authRepositoryProvider)
          .verifyEmail(uid: uid, token: token);
      if (ok) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          message: null,
        );
        return true;
      }
      state = state.copyWith(
        status: AuthStatus.error,
        message: 'Invalid or expired verification link.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: e.toString(),
      );
      return false;
    }
  }

  // ── Token refresh (called by Dio interceptor) ─────────────────────────────

  Future<bool> tryRefreshToken() async {
    try {
      final refresh =
          await _ref.read(tokenStorageProvider).readRefreshToken();
      if (refresh == null || refresh.isEmpty) return false;
      final result =
          await _ref.read(refreshTokenUseCaseProvider)(refresh);
      if (result == null) return false;
      await _ref.read(tokenStorageProvider).writeTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
          );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _ref.read(tokenStorageProvider).clear();
    } catch (_) {
      // Best-effort clear; still reset state.
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ── Cooldown timer ────────────────────────────────────────────────────────

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    state = state.copyWith(resendCooldownSec: seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.resendCooldownSec - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(resendCooldownSec: 0);
      } else {
        state = state.copyWith(resendCooldownSec: remaining);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
