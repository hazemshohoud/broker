import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';
import '../entities/withdrawal.dart';

abstract class CommissionsRepository {
  Future<Either<Failure, Wallet>> getWallet();

  Future<Either<Failure, Unit>> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  });
}
