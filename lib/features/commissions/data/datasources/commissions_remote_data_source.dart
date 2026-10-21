import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/current_user.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/withdrawal.dart';
import '../models/wallet_models.dart';

abstract class CommissionsRemoteDataSource {
  Future<Wallet> getWallet();
  Future<void> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  });
}

class CommissionsRemoteDataSourceImpl implements CommissionsRemoteDataSource {
  CommissionsRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<Wallet> getWallet() async {
    final uid = _auth.requireUid;
    // بدون orderBy عشان مانحتاجش composite index — الترتيب على الجهاز.
    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> byBroker(
      String collection,
    ) async =>
        (await _firestore
                .collection(collection)
                .where('brokerId', isEqualTo: uid)
                .get())
            .docs;

    try {
      final results = await Future.wait<Object>([
        byBroker('commissions'),
        byBroker('withdrawal_requests'),
        _firestore
            .collection('registrations')
            .doc(uid)
            .get()
            .catchError((_) => null as dynamic),
      ]);
      final commissions =
          results[0] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
      final withdrawals =
          results[1] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
      final profile = results[2] as DocumentSnapshot<Map<String, dynamic>>?;

      return Wallet(
        commissions: commissions.map(commissionFromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        withdrawals: withdrawals.map(withdrawalFromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        payoutMethods: payoutMethodsFromRegistration(profile?.data()),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر تحميل العمولات');
    } catch (e) {
      throw ServerException('تعذر تحميل العمولات: $e');
    }
  }

  @override
  Future<void> requestWithdrawal({
    required double amount,
    required PayoutMethod method,
  }) async {
    final uid = _auth.requireUid;
    try {
      await _firestore
          .collection('withdrawal_requests')
          .add(
            withdrawalRequestToMap(
              brokerId: uid,
              amount: amount,
              method: method,
            ),
          );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر إرسال طلب السحب');
    } catch (e) {
      throw ServerException('تعذر إرسال طلب السحب: $e');
    }
  }
}
