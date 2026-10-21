import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/account_status.dart';
import '../repositories/auth_repository.dart';

class SignIn implements UseCase<AccountStatus, SignInParams> {
  SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AccountStatus>> call(SignInParams params) =>
      _repository.signIn(phone: params.phone, pin: params.pin);
}

class SignInParams extends Equatable {
  const SignInParams({required this.phone, required this.pin});

  final String phone;
  final String pin;

  @override
  List<Object?> get props => [phone, pin];
}
