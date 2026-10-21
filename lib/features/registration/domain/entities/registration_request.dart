import 'package:equatable/equatable.dart';

class RegistrationRequest extends Equatable {
  const RegistrationRequest({
    required this.fullName,
    required this.birthDate,
    required this.governorate,
    required this.phone,
    required this.whatsapp,
    required this.pin,
    this.instaPayNumber,
    this.walletNumber,
    this.photoPath,
  });

  final String fullName;
  final DateTime birthDate;
  final String governorate;
  final String phone;
  final String whatsapp;
  final String pin;
  final String? instaPayNumber;
  final String? walletNumber;

  /// Local path of the picked profile photo, if any.
  final String? photoPath;

  @override
  List<Object?> get props => [
    fullName,
    birthDate,
    governorate,
    phone,
    whatsapp,
    pin,
    instaPayNumber,
    walletNumber,
    photoPath,
  ];
}
