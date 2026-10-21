import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/withdrawal.dart';
import '../../domain/repositories/commissions_repository.dart';
import '../datasources/commissions_remote_data_source.dart';

class CommissionsRepositoryImpl implements CommissionsRepository {
  CommissionsRepositoryImpl(this._remoteDataSource);

  final CommissionsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      return Right(await _remoteDataSource.getWallet());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  }) async {
    try {
      await _remoteDataSource.requestWithdrawal(amount: amount, method: method);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
