import 'package:equatable/equatable.dart';

class AdminRegistration extends Equatable {
  const AdminRegistration({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.governorate,
    required this.phone,
    required this.whatsapp,
    required this.status,
    required this.createdAt,
    this.instaPayNumber,
    this.walletNumber,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final DateTime birthDate;
  final String governorate;
  final String phone;
  final String whatsapp;
  final String status;
  final DateTime createdAt;
  final String? instaPayNumber;
  final String? walletNumber;
  final String? photoUrl;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
    id,
    fullName,
    birthDate,
    governorate,
    phone,
    whatsapp,
    status,
    createdAt,
    instaPayNumber,
    walletNumber,
    photoUrl,
  ];
}
