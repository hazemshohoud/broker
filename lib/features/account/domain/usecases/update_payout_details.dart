import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/account_repository.dart';

class UpdatePayoutParams extends Equatable {
  const UpdatePayoutParams({this.instaPayNumber, this.walletNumber});

  final String? instaPayNumber;
  final String? walletNumber;

  @override
  List<Object?> get props => [instaPayNumber, walletNumber];
}

class UpdatePayoutDetails extends UseCase<void, UpdatePayoutParams> {
  UpdatePayoutDetails(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdatePayoutParams params) =>
      _repository.updatePayoutDetails(
        instaPayNumber: params.instaPayNumber,
        walletNumber: params.walletNumber,
      );
}
