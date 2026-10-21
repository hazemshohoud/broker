import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Stream<List<AppNotification>> watchNotifications(String userId);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? metadata,
  });
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore.collection('notifications').snapshots().map((snapshot) {
      final list = <AppNotification>[];
      for (final doc in snapshot.docs) {
        try {
          final model = AppNotificationModel.fromFirestore(doc);
          if (model.userId == userId || model.userId == 'all') {
            list.add(model);
          }
        } catch (_) {}
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore.collection('notifications').get();
      final batch = _firestore.batch();
      var hasUpdates = false;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final docUserId = data['userId']?.toString();
        final isRead = data['isRead'] as bool? ?? false;

        if ((docUserId == userId || docUserId == 'all') && !isRead) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (_) {}
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        if (metadata != null) 'metadata': metadata,
      });
    } catch (_) {}
  }
}
