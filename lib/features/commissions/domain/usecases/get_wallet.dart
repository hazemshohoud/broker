import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/commissions_repository.dart';

class GetWallet extends UseCase<Wallet, NoParams> {
  GetWallet(this._repository);

  final CommissionsRepository _repository;

  @override
  Future<Either<Failure, Wallet>> call(NoParams params) =>
      _repository.getWallet();
}
