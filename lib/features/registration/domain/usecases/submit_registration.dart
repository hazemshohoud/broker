import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/registration_request.dart';
import '../repositories/registration_repository.dart';

class SubmitRegistration implements UseCase<Unit, SubmitRegistrationParams> {
  SubmitRegistration(this._repository);

  final RegistrationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SubmitRegistrationParams params) =>
      _repository.submit(params.request);
}

class SubmitRegistrationParams extends Equatable {
  const SubmitRegistrationParams(this.request);

  final RegistrationRequest request;

  @override
  List<Object?> get props => [request];
}
