import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/developer.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Developer>>> getDevelopers() =>
      _guard(_remoteDataSource.getDevelopers);

  @override
  Future<Either<Failure, List<Offer>>> getOffers() =>
      _guard(_remoteDataSource.getOffers);

  @override
  Future<Either<Failure, List<Compound>>> getCompounds() =>
      _guard(_remoteDataSource.getCompounds);

  @override
  Future<Either<Failure, FilterOptions>> getFilterOptions() =>
      _guard(_remoteDataSource.getFilterOptions);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
