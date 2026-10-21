import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/broker_profile.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._remoteDataSource);

  final AccountRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, BrokerProfile>> getProfile() async {
    try {
      return Right(await _remoteDataSource.getProfile());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePayoutDetails({
    String? instaPayNumber,
    String? walletNumber,
  }) async {
    try {
      await _remoteDataSource.updatePayoutDetails(
        instaPayNumber: instaPayNumber,
        walletNumber: walletNumber,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
