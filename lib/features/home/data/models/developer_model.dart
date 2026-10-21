import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/developer.dart';

class DeveloperModel extends Developer {
  const DeveloperModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.description,
    super.phone,
    super.whatsapp,
    super.order = 0,
  });

  factory DeveloperModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return DeveloperModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String? ?? data['about'] as String?,
      phone: data['phone'] as String?,
      whatsapp: data['whatsapp'] as String?,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      'order': order,
    };
  }
}
