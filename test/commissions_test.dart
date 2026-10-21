import 'package:broker/core/error/failures.dart';
import 'package:broker/features/commissions/domain/entities/commission.dart';
import 'package:broker/features/commissions/domain/entities/wallet.dart';
import 'package:broker/features/commissions/domain/entities/withdrawal.dart';
import 'package:broker/features/commissions/domain/repositories/commissions_repository.dart';
import 'package:broker/features/commissions/domain/usecases/get_wallet.dart';
import 'package:broker/features/commissions/domain/usecases/request_withdrawal.dart';
import 'package:broker/features/commissions/presentation/cubit/commissions_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

final _date = DateTime(2026);
const _instaPay = PayoutMethod(type: PayoutMethodType.instaPay, number: '010');

Commission _commission(double amount, CommissionStatus status) => Commission(
  id: '$amount$status',
  title: 'كمبوند',
  amount: amount,
  status: status,
  createdAt: _date,
);

Withdrawal _withdrawal(double amount, WithdrawalStatus status) => Withdrawal(
  id: '$amount$status',
  amount: amount,
  method: _instaPay,
  status: status,
  createdAt: _date,
);

class _FakeRepository implements CommissionsRepository {
  _FakeRepository(this.wallet);

  Wallet wallet;
  final requested = <double>[];

  @override
  Future<Either<Failure, Wallet>> getWallet() async => Right(wallet);

  @override
  Future<Either<Failure, Unit>> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  }) async {
    requested.add(amount);
    wallet = Wallet(
      commissions: wallet.commissions,
      withdrawals: [
        ...wallet.withdrawals,
        _withdrawal(amount, WithdrawalStatus.pending),
      ],
      payoutMethods: wallet.payoutMethods,
    );
    return const Right(unit);
  }
}

void main() {
  group('Wallet balances', () {
    final wallet = Wallet(
      commissions: [
        _commission(10000, CommissionStatus.approved),
        _commission(5000, CommissionStatus.approved),
        _commission(7000, CommissionStatus.pending),
      ],
      withdrawals: [
        _withdrawal(3000, WithdrawalStatus.completed),
        _withdrawal(2000, WithdrawalStatus.pending),
        _withdrawal(9000, WithdrawalStatus.rejected),
      ],
    );

    test(
      'available = approved - completed - pending; rejected is returned',
      () {
        expect(wallet.availableBalance, 10000);
      },
    );

    test('totals', () {
      expect(wallet.pendingCommissions, 7000);
      expect(wallet.withdrawnTotal, 3000);
      expect(wallet.reservedTotal, 2000);
    });

    test('never negative', () {
      final overdrawn = Wallet(
        withdrawals: [_withdrawal(500, WithdrawalStatus.completed)],
      );
      expect(overdrawn.availableBalance, 0);
    });
  });

  group('RequestWithdrawal', () {
    test(
      'rejects zero and amounts above the balance without calling repo',
      () async {
        final repo = _FakeRepository(const Wallet());
        final usecase = RequestWithdrawal(repo);

        final zero = await usecase(
          const RequestWithdrawalParams(
            amount: 0,
            method: _instaPay,
            availableBalance: 100,
          ),
        );
        final tooMuch = await usecase(
          const RequestWithdrawalParams(
            amount: 101,
            method: _instaPay,
            availableBalance: 100,
          ),
        );

        expect(zero.isLeft(), isTrue);
        expect(tooMuch.isLeft(), isTrue);
        expect(repo.requested, isEmpty);
      },
    );
  });

  group('CommissionsCubit', () {
    test('withdrawal reserves the amount and reloads the wallet', () async {
      final repo = _FakeRepository(
        Wallet(
          commissions: [_commission(1000, CommissionStatus.approved)],
          payoutMethods: const [_instaPay],
        ),
      );
      final cubit = CommissionsCubit(
        getWallet: GetWallet(repo),
        requestWithdrawal: RequestWithdrawal(repo),
      );

      await cubit.load();
      expect(cubit.state.wallet.availableBalance, 1000);

      await cubit.requestWithdrawal(amount: 400, method: _instaPay);
      expect(cubit.state.withdrawStatus, WithdrawStatus.success);
      expect(cubit.state.wallet.availableBalance, 600);
      expect(cubit.state.wallet.reservedTotal, 400);

      await cubit.requestWithdrawal(amount: 700, method: _instaPay);
      expect(cubit.state.withdrawStatus, WithdrawStatus.failure);
      expect(cubit.state.withdrawError, 'المبلغ أكبر من رصيدك المتاح');
      expect(repo.requested, [400]);
    });
  });
}
