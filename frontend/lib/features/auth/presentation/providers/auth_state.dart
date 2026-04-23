enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  verificationPending,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? message;
  final String? pendingEmail;
  final int resendCooldownSec;

  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.pendingEmail,
    this.resendCooldownSec = 0,
  });

  /// BUG FIX: use a sentinel so callers can explicitly clear `message`
  /// by passing `message: null`, while omitting the param preserves the
  /// current value.  A simple `message ?? this.message` would lose the
  /// ability to clear it, so we use a private sentinel object instead.
  static const _keep = Object();

  AuthState copyWith({
    AuthStatus? status,
    Object? message = _keep,
    String? pendingEmail,
    int? resendCooldownSec,
  }) {
    return AuthState(
      status: status ?? this.status,
      // If caller passed null explicitly → clear message.
      // If caller omitted the param → keep existing message.
      message: identical(message, _keep)
          ? this.message
          : message as String?,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      resendCooldownSec: resendCooldownSec ?? this.resendCooldownSec,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message &&
          pendingEmail == other.pendingEmail &&
          resendCooldownSec == other.resendCooldownSec;

  @override
  int get hashCode =>
      status.hashCode ^
      message.hashCode ^
      pendingEmail.hashCode ^
      resendCooldownSec.hashCode;
}
