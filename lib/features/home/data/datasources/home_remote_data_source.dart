import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/compound_model.dart';
import '../models/developer_model.dart';
import '../models/filter_options_model.dart';
import '../models/offer_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<DeveloperModel>> getDevelopers();
  Future<List<OfferModel>> getOffers();
  Future<List<CompoundModel>> getCompounds();
  Future<FilterOptionsModel> getFilterOptions();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<DeveloperModel>> getDevelopers() => _fetch(
    _firestore.collection('developers').orderBy('order'),
    DeveloperModel.fromFirestore,
  );

  @override
  Future<List<OfferModel>> getOffers() => _fetch(
    _firestore.collection('offers').orderBy('order'),
    OfferModel.fromFirestore,
  );

  @override
  Future<List<CompoundModel>> getCompounds() =>
      _fetch(_firestore.collection('compounds'), CompoundModel.fromFirestore);

  @override
  Future<FilterOptionsModel> getFilterOptions() async {
    try {
      final doc = await _firestore
          .collection('config')
          .doc('filter_options')
          .get();
      return FilterOptionsModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'حدث خطأ في الخادم');
    }
  }

  Future<List<T>> _fetch<T>(
    Query<Map<String, dynamic>> query,
    T Function(DocumentSnapshot<Map<String, dynamic>>) mapper,
  ) async {
    try {
      final snapshot = await query.get();
      return snapshot.docs.map(mapper).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'حدث خطأ في الخادم');
    } catch (e) {
      throw ServerException('خطأ في استرجاع البيانات: $e');
    }
  }
}
