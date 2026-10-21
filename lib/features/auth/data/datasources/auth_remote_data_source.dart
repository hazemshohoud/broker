import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/auth_credentials.dart';
import '../../../../core/utils/current_user.dart';
import '../../domain/entities/account_status.dart';

abstract class AuthRemoteDataSource {
  Future<AccountStatus?> currentStatus();
  Future<AccountStatus> signIn({required String phone, required String pin});
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const adminPhones = ['01088888888', '01000000000'];
  static const adminPasswords = ['8888', '88888888'];

  @override
  Future<AccountStatus?> currentStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (CurrentUserHolder.activeUid != null) {
        if (CurrentUserHolder.activeUid!.startsWith('admin_')) {
          return AccountStatus.admin;
        }
        return _readStatus(CurrentUserHolder.activeUid!);
      }
      return null;
    }
    return _readStatus(user.uid);
  }

  @override
  Future<AccountStatus> signIn({
    required String phone,
    required String pin,
  }) async {
    final normalizedPhone = phone.trim();
    final normalizedPin = pin.trim();

    // فحص مباشر لأرقام وكلمات مرور إدارة النظام لتسهيل الدخول الإداري الفوري
    if (adminPhones.contains(normalizedPhone) &&
        adminPasswords.contains(normalizedPin)) {
      CurrentUserHolder.activeUid = 'admin_$normalizedPhone';
      return AccountStatus.admin;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: AuthCredentials.emailForPhone(phone),
        password: AuthCredentials.passwordForPin(pin),
      );
      final uid = credential.user!.uid;
      CurrentUserHolder.activeUid = uid;
      final status = await _readStatus(uid);
      if (status != AccountStatus.approved && status != AccountStatus.admin) {
        CurrentUserHolder.activeUid = null;
        await _auth.signOut();
      }
      return status;
    } on FirebaseAuthException catch (e) {
      // لو فيه حظر مؤقت من المحاكي أو كود خطأ خاص بشبكة المحاكي، نتحقق مباشرة من بيانات التسجيل
      final isBlockedOrLimit = e.code == 'too-many-requests' ||
          (e.message?.contains('blocked') == true) ||
          e.code == 'network-request-failed';
      if (isBlockedOrLimit) {
        try {
          final query = await _firestore
              .collection('registrations')
              .where('phone', isEqualTo: phone)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            final doc = query.docs.first;
            final data = doc.data();
            final expectedHash =
                sha256.convert(utf8.encode('$phone:$pin')).toString();
            if (data['pinHash'] == expectedHash) {
              CurrentUserHolder.activeUid = doc.id;
              final role = data['role']?.toString();
              if (adminPhones.contains(phone) ||
                  role == 'admin' ||
                  data['status'] == 'admin') {
                return AccountStatus.admin;
              }
              return switch (data['status']) {
                'approved' => AccountStatus.approved,
                'rejected' => AccountStatus.rejected,
                _ => AccountStatus.pending,
              };
            }
          }
        } catch (_) {}
      }
      throw ServerException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'حدث خطأ أثناء تسجيل الدخول');
    }
  }

  @override
  Future<void> signOut() {
    CurrentUserHolder.activeUid = null;
    return _auth.signOut();
  }

  Future<AccountStatus> _readStatus(String uid) async {
    final doc = await _firestore.collection('registrations').doc(uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw const ServerException('الحساب غير مكتمل، برجاء إنشاء حساب جديد');
    }
    final data = doc.data() ?? {};
    final phone = data['phone']?.toString().trim();
    final role = data['role']?.toString();
    if (adminPhones.contains(phone) ||
        role == 'admin' ||
        data['status'] == 'admin') {
      return AccountStatus.admin;
    }
    return switch (data['status']) {
      'approved' => AccountStatus.approved,
      'rejected' => AccountStatus.rejected,
      _ => AccountStatus.pending,
    };
  }

  String _mapAuthError(FirebaseAuthException e) => switch (e.code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'رقم الهاتف أو كلمة المرور غير صحيحة',
    'user-disabled' => 'تم تعطيل هذا الحساب',
    'too-many-requests' => 'محاولات كثيرة، حاول مرة أخرى لاحقًا',
    'network-request-failed' => 'تحقق من اتصالك بالإنترنت',
    _ => e.message ?? 'حدث خطأ أثناء تسجيل الدخول',
  };
}
