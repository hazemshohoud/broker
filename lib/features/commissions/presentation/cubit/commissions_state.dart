part of 'commissions_cubit.dart';

enum CommissionsStatus { loading, success, failure }

enum WithdrawStatus { idle, submitting, success, failure }

class CommissionsState extends Equatable {
  const CommissionsState({
    this.status = CommissionsStatus.loading,
    this.wallet = const Wallet(),
    this.withdrawStatus = WithdrawStatus.idle,
    this.errorMessage,
    this.withdrawError,
  });

  final CommissionsStatus status;
  final Wallet wallet;
  final WithdrawStatus withdrawStatus;
  final String? errorMessage;
  final String? withdrawError;

  CommissionsState copyWith({
    CommissionsStatus? status,
    Wallet? wallet,
    WithdrawStatus? withdrawStatus,
    String? errorMessage,
    String? withdrawError,
  }) => CommissionsState(
    status: status ?? this.status,
    wallet: wallet ?? this.wallet,
    withdrawStatus: withdrawStatus ?? this.withdrawStatus,
    errorMessage: errorMessage ?? this.errorMessage,
    withdrawError: withdrawError,
  );

  @override
  List<Object?> get props => [
    status,
    wallet,
    withdrawStatus,
    errorMessage,
    withdrawError,
  ];
}
