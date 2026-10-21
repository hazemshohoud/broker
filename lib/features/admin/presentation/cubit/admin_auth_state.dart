import 'package:equatable/equatable.dart';

sealed class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {
  const AdminAuthInitial();
}

class AdminAuthLoading extends AdminAuthState {
  const AdminAuthLoading();
}

class AdminAuthAuthenticated extends AdminAuthState {
  const AdminAuthAuthenticated({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AdminAuthFailure extends AdminAuthState {
  const AdminAuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
