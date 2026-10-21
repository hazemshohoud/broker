import 'package:equatable/equatable.dart';

class AdminCommission extends Equatable {
  const AdminCommission({
    required this.id,
    required this.brokerId,
    this.brokerName,
    this.brokerPhone,
    required this.amount,
    required this.title,
    this.compoundName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String brokerId;
  final String? brokerName;
  final String? brokerPhone;
  final double amount;
  final String title;
  final String? compoundName;
  final String status;
  final DateTime createdAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    id,
    brokerId,
    brokerName,
    brokerPhone,
    amount,
    title,
    compoundName,
    status,
    createdAt,
  ];
}
