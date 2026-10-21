import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/developer.dart';
import '../repositories/home_repository.dart';

class GetDevelopers implements UseCase<List<Developer>, NoParams> {
  GetDevelopers(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<Developer>>> call(NoParams params) =>
      _repository.getDevelopers();
}
