import 'package:equatable/equatable.dart';

enum WithdrawalStatus { pending, completed, rejected }

enum PayoutMethodType { instaPay, wallet }

/// وسيلة استلام العمولة المسجلة في حساب الوسيط.
class PayoutMethod extends Equatable {
  const PayoutMethod({required this.type, required this.number});

  final PayoutMethodType type;
  final String number;

  @override
  List<Object?> get props => [type, number];
}

/// طلب سحب عمولة — الأدمن بيبدّل حالته (مكتمل/مرفوض).
class Withdrawal extends Equatable {
  const Withdrawal({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final PayoutMethod method;
  final WithdrawalStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, amount, method, status, createdAt];
}
