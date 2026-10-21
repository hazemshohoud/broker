import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/onboarding_item.dart';

class OnboardingItemModel extends OnboardingItem {
  const OnboardingItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.order,
  });

  factory OnboardingItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OnboardingItemModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  factory OnboardingItemModel.fromMap(String id, Map<String, dynamic> map) {
    return OnboardingItemModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
