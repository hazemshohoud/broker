part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

/// مفيش جلسة — المستخدم محتاج يسجل دخول.
final class AuthNeedsLogin extends AuthState {
  const AuthNeedsLogin();
}

/// جلسة سليمة وحسابه معتمد.
final class AuthApproved extends AuthState {
  const AuthApproved();
}

/// حساب مسؤول / إدارة النظام — يوجه مباشرة للوحة التحكم.
final class AuthAdmin extends AuthState {
  const AuthAdmin();
}

/// الحساب موجود لكن لسه بيتراجع.
final class AuthPending extends AuthState {
  const AuthPending();
}

/// طلب التسجيل اترفض.
final class AuthRejected extends AuthState {
  const AuthRejected(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
