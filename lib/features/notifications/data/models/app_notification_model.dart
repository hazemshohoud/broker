import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.metadata,
  });

  factory AppNotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawCreated = data['createdAt'];
    final createdAt = rawCreated is Timestamp
        ? rawCreated.toDate()
        : DateTime.tryParse(rawCreated?.toString() ?? '') ?? DateTime.now();

    return AppNotificationModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: createdAt,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
