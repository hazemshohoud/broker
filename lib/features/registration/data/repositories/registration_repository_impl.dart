import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/repositories/registration_repository.dart';
import '../datasources/registration_remote_data_source.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  RegistrationRepositoryImpl(this._remoteDataSource);

  final RegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Unit>> submit(RegistrationRequest request) async {
    try {
      await _remoteDataSource.submit(request);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
