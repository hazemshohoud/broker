import 'package:equatable/equatable.dart';

class AdminWithdrawal extends Equatable {
  const AdminWithdrawal({
    required this.id,
    required this.brokerId,
    required this.amount,
    required this.methodType,
    required this.methodNumber,
    required this.status,
    required this.createdAt,
    this.brokerName,
    this.brokerPhone,
  });

  final String id;
  final String brokerId;
  final double amount;
  final String methodType;
  final String methodNumber;
  final String status;
  final DateTime createdAt;
  final String? brokerName;
  final String? brokerPhone;

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    id,
    brokerId,
    amount,
    methodType,
    methodNumber,
    status,
    createdAt,
    brokerName,
    brokerPhone,
  ];
}
