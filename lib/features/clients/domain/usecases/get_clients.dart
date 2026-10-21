import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/broker_client.dart';
import '../repositories/clients_repository.dart';

class GetClients extends UseCase<List<BrokerClient>, NoParams> {
  GetClients(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Either<Failure, List<BrokerClient>>> call(NoParams params) =>
      _repository.getClients();
}

class GetCompoundNames extends UseCase<List<String>, NoParams> {
  GetCompoundNames(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getCompoundNames();
}
