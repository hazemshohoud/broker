import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account_status.dart';

abstract class AuthRepository {
  /// حالة الحساب الحالي، أو `null` لو مفيش جلسة دخول.
  Future<Either<Failure, AccountStatus?>> currentStatus();

  Future<Either<Failure, AccountStatus>> signIn({
    required String phone,
    required String pin,
  });

  Future<Either<Failure, Unit>> signOut();
}
