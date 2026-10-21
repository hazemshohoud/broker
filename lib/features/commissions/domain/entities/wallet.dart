import 'package:equatable/equatable.dart';

import 'commission.dart';
import 'withdrawal.dart';

/// محفظة الوسيط: العمولات + طلبات السحب + وسائل الاستلام.
class Wallet extends Equatable {
  const Wallet({
    this.commissions = const [],
    this.withdrawals = const [],
    this.payoutMethods = const [],
  });

  final List<Commission> commissions;
  final List<Withdrawal> withdrawals;
  final List<PayoutMethod> payoutMethods;

  double get _approvedCommissions => commissions
      .where((c) => c.status == CommissionStatus.approved)
      .fold(0.0, (sum, c) => sum + c.amount);

  /// عمولات لسه في مرحلة الاعتماد — مش متاحة للسحب.
  double get pendingCommissions => commissions
      .where((c) => c.status == CommissionStatus.pending)
      .fold(0.0, (sum, c) => sum + c.amount);

  /// إجمالي المبالغ اللي اتحوّلت فعلًا.
  double get withdrawnTotal => withdrawals
      .where((w) => w.status == WithdrawalStatus.completed)
      .fold(0.0, (sum, w) => sum + w.amount);

  /// مبالغ محجوزة في طلبات سحب قيد التنفيذ.
  double get reservedTotal => withdrawals
      .where((w) => w.status == WithdrawalStatus.pending)
      .fold(0.0, (sum, w) => sum + w.amount);

  /// المتاح للسحب = المعتمد - المسحوب - المحجوز (المرفوض بيرجع تلقائيًا).
  double get availableBalance {
    final available = _approvedCommissions - withdrawnTotal - reservedTotal;
    return available < 0 ? 0 : available;
  }

  @override
  List<Object?> get props => [commissions, withdrawals, payoutMethods];
}
