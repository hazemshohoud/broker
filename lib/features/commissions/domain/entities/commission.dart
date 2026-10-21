import 'package:equatable/equatable.dart';

enum CommissionStatus { pending, approved }

/// عمولة الوسيط عن صفقة — الأدمن بيضيفها وبيبدّل حالتها.
class Commission extends Equatable {
  const Commission({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    this.details,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final CommissionStatus status;

  /// تفاصيل الصفقة (نوع العقار/المساحة) — اختيارية.
  final String? details;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, amount, status, details, createdAt];
}
