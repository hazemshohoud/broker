import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/withdrawal.dart';
import '../repositories/commissions_repository.dart';

class RequestWithdrawal extends UseCase<Unit, RequestWithdrawalParams> {
  RequestWithdrawal(this._repository);

  final CommissionsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(RequestWithdrawalParams params) async {
    if (params.amount <= 0) {
      return const Left(ValidationFailure('اكتب مبلغ صحيح'));
    }
    if (params.amount > params.availableBalance) {
      return const Left(ValidationFailure('المبلغ أكبر من رصيدك المتاح'));
    }
    return _repository.requestWithdrawal(
      amount: params.amount,
      method: params.method,
    );
  }
}

class RequestWithdrawalParams extends Equatable {
  const RequestWithdrawalParams({
    required this.amount,
    required this.method,
    required this.availableBalance,
  });

  final double amount;
  final PayoutMethod method;
  final double availableBalance;

  @override
  List<Object?> get props => [amount, method, availableBalance];
}
