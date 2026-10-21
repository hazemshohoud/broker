import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/current_user.dart';
import '../../domain/entities/broker_profile.dart';

abstract class AccountRemoteDataSource {
  Future<BrokerProfile> getProfile();
  Future<void> updatePayoutDetails({
    String? instaPayNumber,
    String? walletNumber,
  });
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<BrokerProfile> getProfile() async {
    final uid = _auth.requireUid;
    try {
      final doc = await _firestore.collection('registrations').doc(uid).get();
      final data = doc.data();
      if (data == null) {
        final phone =
            _auth.currentUser?.email?.split('@').first ?? '01011112222';
        return BrokerProfile(
          fullName: _auth.currentUser?.displayName?.isNotEmpty == true
              ? _auth.currentUser!.displayName!
              : 'وسيط بروكر',
          birthDate: DateTime(1998, 1, 1),
          governorate: 'بني سويف',
          phone: phone,
          whatsapp: phone,
          status: 'approved',
          instaPayNumber: phone,
          walletNumber: phone,
        );
      }
      return BrokerProfile(
        fullName: data['fullName']?.toString() ?? '',
        birthDate: _parseDate(data['birthDate']),
        governorate: data['governorate']?.toString() ?? 'بني سويف',
        phone: data['phone']?.toString() ?? '',
        whatsapp: data['whatsapp']?.toString() ?? '',
        status: data['status']?.toString() ?? 'pending',
        instaPayNumber: data['instaPayNumber']?.toString(),
        walletNumber: data['walletNumber']?.toString(),
        photoUrl: data['photoUrl']?.toString(),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر تحميل بيانات الحساب');
    } catch (e) {
      throw ServerException('تعذر تحميل بيانات الحساب: $e');
    }
  }

  @override
  Future<void> updatePayoutDetails({
    String? instaPayNumber,
    String? walletNumber,
  }) async {
    final uid = _auth.requireUid;
    try {
      await _firestore.collection('registrations').doc(uid).set({
        'instaPayNumber': (instaPayNumber != null && instaPayNumber.trim().isNotEmpty)
            ? instaPayNumber.trim()
            : null,
        'walletNumber': (walletNumber != null && walletNumber.trim().isNotEmpty)
            ? walletNumber.trim()
            : null,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر تحديث بيانات استلام الأرباح');
    } catch (e) {
      throw ServerException('تعذر تحديث بيانات استلام الأرباح: $e');
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
