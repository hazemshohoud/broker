import 'package:equatable/equatable.dart';

/// بيانات الوسيط المعروضة في صفحة "حسابي" — مصدرها مستند التسجيل.
class BrokerProfile extends Equatable {
  const BrokerProfile({
    required this.fullName,
    required this.birthDate,
    required this.governorate,
    required this.phone,
    required this.whatsapp,
    required this.status,
    this.instaPayNumber,
    this.walletNumber,
    this.photoUrl,
  });

  final String fullName;
  final DateTime birthDate;
  final String governorate;
  final String phone;
  final String whatsapp;
  final String status;
  final String? instaPayNumber;
  final String? walletNumber;
  final String? photoUrl;

  bool get isApproved => status == 'approved';

  @override
  List<Object?> get props => [
    fullName,
    birthDate,
    governorate,
    phone,
    whatsapp,
    status,
    instaPayNumber,
    walletNumber,
    photoUrl,
  ];
}
