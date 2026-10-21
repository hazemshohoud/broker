import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/current_user.dart';
import '../../domain/entities/broker_client.dart';
import '../models/client_model.dart';

abstract class ClientsRemoteDataSource {
  Future<List<BrokerClient>> getClients();
  Future<List<String>> getCompoundNames();
  Future<void> addClient({
    required String name,
    required String phone,
    required String interest,
    String? note,
  });
  Future<void> deleteClient(String clientId);
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  ClientsRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _firestore.collection('clients');

  @override
  Future<List<BrokerClient>> getClients() async {
    final uid = _auth.requireUid;
    try {
      // بدون orderBy عشان مانحتاجش composite index — الترتيب على الجهاز.
      final snapshot = await _clients.where('brokerId', isEqualTo: uid).get();
      return snapshot.docs.map(clientFromFirestore).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر تحميل العملاء');
    } catch (e) {
      throw ServerException('تعذر تحميل العملاء: $e');
    }
  }

  @override
  Future<List<String>> getCompoundNames() async {
    try {
      final snapshot = await _firestore.collection('compounds').get();
      return snapshot.docs
          .map((doc) => doc.data()['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر تحميل الكمبوندات');
    } catch (e) {
      throw ServerException('تعذر تحميل الكمبوندات: $e');
    }
  }

  @override
  Future<void> addClient({
    required String name,
    required String phone,
    required String interest,
    String? note,
  }) async {
    final uid = _auth.requireUid;
    try {
      await _clients.add(
        clientToMap(
          brokerId: uid,
          name: name,
          phone: phone,
          interest: interest,
          note: note,
        ),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر إضافة العميل');
    } catch (e) {
      throw ServerException('تعذر إضافة العميل: $e');
    }
  }

  @override
  Future<void> deleteClient(String clientId) async {
    try {
      await _clients.doc(clientId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'تعذر حذف العميل');
    } catch (e) {
      throw ServerException('تعذر حذف العميل: $e');
    }
  }
}
