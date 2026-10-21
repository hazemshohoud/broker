import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/compound.dart';
import '../repositories/home_repository.dart';

class GetCompounds implements UseCase<List<Compound>, NoParams> {
  GetCompounds(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<Compound>>> call(NoParams params) =>
      _repository.getCompounds();
}
