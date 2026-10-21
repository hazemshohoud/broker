import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/broker_client.dart';

BrokerClient clientFromFirestore(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final createdAt = data['createdAt'];
  return BrokerClient(
    id: doc.id,
    brokerId: data['brokerId']?.toString() ?? '',
    name: data['name']?.toString() ?? '',
    phone: data['phone']?.toString() ?? '',
    interest: data['interest']?.toString() ?? '',
    note: data['note']?.toString(),
    createdAt: createdAt is Timestamp
        ? createdAt.toDate()
        : (createdAt is String
            ? DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0)),
  );
}

Map<String, Object?> clientToMap({
  required String brokerId,
  required String name,
  required String phone,
  required String interest,
  String? note,
}) => {
  'brokerId': brokerId,
  'name': name,
  'phone': phone,
  'interest': interest,
  if (note != null) 'note': note,
  'createdAt': FieldValue.serverTimestamp(),
};
