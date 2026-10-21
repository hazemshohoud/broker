import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/account_status.dart';
import '../repositories/auth_repository.dart';

class GetSessionStatus implements UseCase<AccountStatus?, NoParams> {
  GetSessionStatus(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AccountStatus?>> call(NoParams params) =>
      _repository.currentStatus();
}
