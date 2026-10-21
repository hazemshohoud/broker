import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/broker_profile.dart';
import '../repositories/account_repository.dart';

class GetProfile extends UseCase<BrokerProfile, NoParams> {
  GetProfile(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, BrokerProfile>> call(NoParams params) =>
      _repository.getProfile();
}
