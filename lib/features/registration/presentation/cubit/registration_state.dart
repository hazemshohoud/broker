part of 'registration_cubit.dart';

sealed class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

final class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

final class RegistrationSubmitting extends RegistrationState {
  const RegistrationSubmitting();
}

final class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess();
}

final class RegistrationFailure extends RegistrationState {
  const RegistrationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
