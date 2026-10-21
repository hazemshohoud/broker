import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/offer.dart';

class OfferModel extends Offer {
  const OfferModel({required super.id, required super.title, super.imageUrl});

  factory OfferModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OfferModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }
}
