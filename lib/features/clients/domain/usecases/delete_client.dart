import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/clients_repository.dart';

class DeleteClient extends UseCase<Unit, String> {
  DeleteClient(this._repository);

  final ClientsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String clientId) =>
      _repository.deleteClient(clientId);
}
