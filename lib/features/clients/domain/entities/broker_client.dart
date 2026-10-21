import 'package:equatable/equatable.dart';

/// عميل سجّله الوسيط لمتابعته — اسمه ورقمه والكمبوند/العقار اللي كان مهتم بيه.
class BrokerClient extends Equatable {
  const BrokerClient({
    required this.id,
    required this.brokerId,
    required this.name,
    required this.phone,
    required this.interest,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String brokerId;
  final String name;
  final String phone;

  /// إيه اللي العميل كان مهتم بيه (اسم كمبوند أو وصف حر).
  final String interest;
  final String? note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    brokerId,
    name,
    phone,
    interest,
    note,
    createdAt,
  ];
}
