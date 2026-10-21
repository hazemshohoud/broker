import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/withdrawal.dart';
import '../../domain/usecases/get_wallet.dart';
import '../../domain/usecases/request_withdrawal.dart';

part 'commissions_state.dart';

class CommissionsCubit extends Cubit<CommissionsState> {
  CommissionsCubit({
    required GetWallet getWallet,
    required RequestWithdrawal requestWithdrawal,
  }) : _getWallet = getWallet,
       _requestWithdrawal = requestWithdrawal,
       super(const CommissionsState());

  final GetWallet _getWallet;
  final RequestWithdrawal _requestWithdrawal;

  Future<void> load() async {
    // أول تحميل بس اللي بيعرض loading — الـ refresh بيسيب البيانات ظاهرة.
    if (state.status == CommissionsStatus.failure) {
      emit(state.copyWith(status: CommissionsStatus.loading));
    }
    final result = await _getWallet(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommissionsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (wallet) => emit(
        state.copyWith(status: CommissionsStatus.success, wallet: wallet),
      ),
    );
  }

  Future<void> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  }) async {
    emit(state.copyWith(withdrawStatus: WithdrawStatus.submitting));
    final result = await _requestWithdrawal(
      RequestWithdrawalParams(
        amount: amount,
        method: method,
        availableBalance: state.wallet.availableBalance,
      ),
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          withdrawStatus: WithdrawStatus.failure,
          withdrawError: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(withdrawStatus: WithdrawStatus.success));
        await load();
      },
    );
  }

  void resetWithdrawStatus() =>
      emit(state.copyWith(withdrawStatus: WithdrawStatus.idle));
}
