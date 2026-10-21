part of 'account_cubit.dart';

enum AccountStatus { loading, success, failure, signedOut }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.loading,
    this.profile,
    this.errorMessage,
  });

  final AccountStatus status;
  final BrokerProfile? profile;
  final String? errorMessage;

  AccountState copyWith({
    AccountStatus? status,
    BrokerProfile? profile,
    String? errorMessage,
  }) => AccountState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
