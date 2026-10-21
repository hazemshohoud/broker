import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/developer.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../../../home/domain/entities/offer.dart';
import '../../domain/entities/admin_commission.dart';
import '../../domain/entities/admin_registration.dart';
import '../../domain/entities/admin_viewing_request.dart';
import '../../domain/entities/admin_withdrawal.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.registrations = const [],
    this.compounds = const [],
    this.developers = const [],
    this.offers = const [],
    this.withdrawals = const [],
    this.viewingRequests = const [],
    this.commissions = const [],
    this.filterOptions = const FilterOptions(),
    this.errorMessage,
    this.actionMessage,
    this.isSaving = false,
  });

  final AdminStatus status;
  final List<AdminRegistration> registrations;
  final List<Compound> compounds;
  final List<Developer> developers;
  final List<Offer> offers;
  final List<AdminWithdrawal> withdrawals;
  final List<AdminViewingRequest> viewingRequests;
  final List<AdminCommission> commissions;
  final FilterOptions filterOptions;
  final String? errorMessage;
  final String? actionMessage;
  final bool isSaving;

  int get pendingRegistrationsCount =>
      registrations.where((r) => r.isPending).length;

  int get pendingWithdrawalsCount =>
      withdrawals.where((w) => w.isPending).length;

  int get pendingViewingRequestsCount =>
      viewingRequests.where((v) => v.isPending).length;

  int get pendingCommissionsCount =>
      commissions.where((c) => c.isPending).length;

  AdminState copyWith({
    AdminStatus? status,
    List<AdminRegistration>? registrations,
    List<Compound>? compounds,
    List<Developer>? developers,
    List<Offer>? offers,
    List<AdminWithdrawal>? withdrawals,
    List<AdminViewingRequest>? viewingRequests,
    List<AdminCommission>? commissions,
    FilterOptions? filterOptions,
    String? errorMessage,
    String? actionMessage,
    bool? isSaving,
  }) {
    return AdminState(
      status: status ?? this.status,
      registrations: registrations ?? this.registrations,
      compounds: compounds ?? this.compounds,
      developers: developers ?? this.developers,
      offers: offers ?? this.offers,
      withdrawals: withdrawals ?? this.withdrawals,
      viewingRequests: viewingRequests ?? this.viewingRequests,
      commissions: commissions ?? this.commissions,
      filterOptions: filterOptions ?? this.filterOptions,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    status,
    registrations,
    compounds,
    developers,
    offers,
    withdrawals,
    viewingRequests,
    commissions,
    filterOptions,
    errorMessage,
    actionMessage,
    isSaving,
  ];
}
