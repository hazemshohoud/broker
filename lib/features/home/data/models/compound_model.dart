import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/compound.dart';

class CompoundModel extends Compound {
  const CompoundModel({
    required super.id,
    required super.name,
    required super.location,
    required super.developerName,
    required super.developerStartPrice,
    required super.commission,
    required super.propertyTypes,
    super.resaleStartPrice,
    super.phone,
    super.whatsapp,
    super.imageUrl,
    super.imageUrls,
    super.developerLogoUrl,
    super.isProject = false,
    super.projectImageUrl,
    super.region,
    super.district,
    super.readiness,
    super.finishing,
    super.area,
    super.deliveryDate,
    super.mapUrl,
    super.latitude,
    super.longitude,
    super.amenities,
    super.faqs,
    super.attachments,
  });

  factory CompoundModel.fromMap(String id, Map<String, dynamic> data) {
    final rawUrls = _toStringList(data['imageUrls']);
    final legacyUrl = data['imageUrl']?.toString();
    final projectUrl = data['projectImageUrl']?.toString();
    final effectiveImages = rawUrls.isNotEmpty
        ? rawUrls
        : (legacyUrl != null && legacyUrl.isNotEmpty
            ? [legacyUrl]
            : (projectUrl != null && projectUrl.isNotEmpty ? [projectUrl] : const <String>[]));

    final isProjectVal = data['isProject'] == true ||
        data['isFeaturedProject'] == true ||
        data['showInProjects'] == true ||
        data['type'] == 'project';

    return CompoundModel(
      id: id,
      name: data['name']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      developerName: data['developerName']?.toString() ?? '',
      developerStartPrice: _toDouble(data['developerStartPrice']),
      resaleStartPrice: _toNullableDouble(data['resaleStartPrice']),
      commission: _toDouble(data['commission']),
      propertyTypes: _toStringList(data['propertyTypes']),
      phone: data['phone']?.toString(),
      whatsapp: data['whatsapp']?.toString() ?? data['phone']?.toString(),
      imageUrl: effectiveImages.firstOrNull ?? legacyUrl,
      imageUrls: effectiveImages,
      developerLogoUrl: data['developerLogoUrl']?.toString(),
      isProject: isProjectVal,
      projectImageUrl: data['projectImageUrl']?.toString(),
      region: data['region']?.toString(),
      district: data['district']?.toString(),
      readiness: data['readiness']?.toString(),
      finishing: data['finishing']?.toString(),
      area: data['area']?.toString(),
      deliveryDate: data['deliveryDate']?.toString(),
      mapUrl: data['mapUrl']?.toString(),
      latitude: _toNullableDouble(data['latitude']),
      longitude: _toNullableDouble(data['longitude']),
      amenities: _toStringMap(data['amenities']),
      faqs: _toStringMap(data['faqs']),
      attachments: _toMapList(data['attachments']),
    );
  }

  factory CompoundModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CompoundModel.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  static double _toDouble(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) return [value];
    return const [];
  }

  static Map<String, String>? _toStringMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return null;
  }

  static List<Map<String, String>>? _toMapList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          return e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        }
        return <String, String>{};
      }).toList();
    }
    return null;
  }
}
