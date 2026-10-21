import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/registration_request.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, Unit>> submit(RegistrationRequest request);
}
