import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/broker_profile.dart';

abstract class AccountRepository {
  Future<Either<Failure, BrokerProfile>> getProfile();
  Future<Either<Failure, void>> updatePayoutDetails({
    String? instaPayNumber,
    String? walletNumber,
  });
}
