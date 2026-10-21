import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/offer.dart';
import '../repositories/home_repository.dart';

class GetOffers implements UseCase<List<Offer>, NoParams> {
  GetOffers(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<Offer>>> call(NoParams params) =>
      _repository.getOffers();
}
