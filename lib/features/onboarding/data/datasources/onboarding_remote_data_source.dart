import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../domain/entities/onboarding_item.dart';
import '../models/onboarding_item_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingItem>> getOnboardingItems({bool forceRefresh = false});
  Stream<List<OnboardingItem>> watchOnboardingItems();
  Future<void> addOnboardingItem({
    required String title,
    required String description,
    required String imageUrl,
    required int order,
  });
  Future<void> deleteOnboardingItem(String id);
  Future<void> seedDefaultItems();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static List<OnboardingItem>? _cachedItems;

  static List<OnboardingItem> get cachedOrDefaults =>
      _cachedItems ?? OnboardingItem.defaults;

  /// تحميل مسبق فوري لصور شاشات الترحيب من اللحظة الأولى لفتح التطبيق (Splash)
  static Future<void> preloadImages(BuildContext context) async {
    // 1. كاش فوري للصور الافتراضية
    for (final def in OnboardingItem.defaults) {
      if (!context.mounted) return;
      final url = CloudinaryService.optimizeUrl(def.imageUrl);
      precacheImage(NetworkImage(url), context).catchError((_) {});
    }

    // 2. تحميل البيانات من فايرستور وكاش الصور المحدثة
    try {
      final items = await OnboardingRemoteDataSourceImpl().getOnboardingItems(
        forceRefresh: true,
      );
      for (final item in items) {
        if (!context.mounted) return;
        final url = CloudinaryService.optimizeUrl(item.imageUrl);
        precacheImage(NetworkImage(url), context).catchError((_) {});
      }
    } catch (_) {}
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('onboarding');

  @override
  Future<List<OnboardingItem>> getOnboardingItems({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedItems != null && _cachedItems!.isNotEmpty) {
      return _cachedItems!;
    }
    try {
      final snap = await _collection.orderBy('order').get();
      if (snap.docs.isEmpty) {
        _cachedItems = OnboardingItem.defaults;
        return OnboardingItem.defaults;
      }
      final items =
          snap.docs.map((doc) => OnboardingItemModel.fromFirestore(doc)).toList();
      _cachedItems = items;
      return items;
    } catch (_) {
      _cachedItems = OnboardingItem.defaults;
      return OnboardingItem.defaults;
    }
  }

  @override
  Stream<List<OnboardingItem>> watchOnboardingItems() {
    return _collection.orderBy('order').snapshots().map((snap) {
      if (snap.docs.isEmpty) {
        return OnboardingItem.defaults;
      }
      return snap.docs.map((doc) => OnboardingItemModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addOnboardingItem({
    required String title,
    required String description,
    required String imageUrl,
    required int order,
  }) async {
    _cachedItems = null;
    await _collection.add({
      'title': title.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl.trim(),
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteOnboardingItem(String id) async {
    _cachedItems = null;
    await _collection.doc(id).delete();
  }

  @override
  Future<void> seedDefaultItems() async {
    _cachedItems = null;
    final batch = _firestore.batch();
    for (final item in OnboardingItem.defaults) {
      final docRef = _collection.doc();
      batch.set(docRef, {
        'title': item.title,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'order': item.order,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
