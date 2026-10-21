import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/compound.dart';
import '../entities/developer.dart';
import '../entities/filter_options.dart';
import '../entities/offer.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Developer>>> getDevelopers();
  Future<Either<Failure, List<Offer>>> getOffers();
  Future<Either<Failure, List<Compound>>> getCompounds();
  Future<Either<Failure, FilterOptions>> getFilterOptions();
}
