import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../../domain/entities/registration_request.dart';

extension RegistrationModel on RegistrationRequest {
  Map<String, dynamic> toMap({String? photoUrl, bool isAdmin = false}) {
    return {
      'fullName': fullName,
      'birthDate': Timestamp.fromDate(birthDate),
      'governorate': governorate,
      'phone': phone,
      'whatsapp': whatsapp,
      'pinHash': _hashPin(pin, phone),
      'instaPayNumber': instaPayNumber,
      'walletNumber': walletNumber,
      'photoUrl': photoUrl,
      'role': isAdmin ? 'admin' : 'broker',
      'status': isAdmin ? 'approved' : 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
