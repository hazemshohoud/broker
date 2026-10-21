import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/filter_options.dart';
import '../repositories/home_repository.dart';

class GetFilterOptions implements UseCase<FilterOptions, NoParams> {
  GetFilterOptions(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, FilterOptions>> call(NoParams params) =>
      _repository.getFilterOptions();
}
