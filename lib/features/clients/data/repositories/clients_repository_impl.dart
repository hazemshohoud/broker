import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/broker_client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_data_source.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  ClientsRepositoryImpl(this._remoteDataSource);

  final ClientsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<BrokerClient>>> getClients() async {
    try {
      return Right(await _remoteDataSource.getClients());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCompoundNames() async {
    try {
      return Right(await _remoteDataSource.getCompoundNames());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> addClient({
    required String name,
    required String phone,
    required String interest,
    String? note,
  }) async {
    try {
      await _remoteDataSource.addClient(
        name: name,
        phone: phone,
        interest: interest,
        note: note,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteClient(String clientId) async {
    try {
      await _remoteDataSource.deleteClient(clientId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
