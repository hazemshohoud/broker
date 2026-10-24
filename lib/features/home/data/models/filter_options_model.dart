import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/filter_options.dart';

/// `config/filter_options` في Firestore — الأدمن بيعدّله من لوحة التحكم.
class FilterOptionsModel extends FilterOptions {
  const FilterOptionsModel({
    super.propertyTypes,
    super.regions,
    super.readinessStatuses,
    super.finishings,
    super.amenities,
  });

  factory FilterOptionsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    List<String> strings(String key) {
      final raw = data[key];
      if (raw is List) {
        return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    final rawRegions = data['regions'];
    final regions = <Region>[];
    if (rawRegions is List) {
      for (final r in rawRegions) {
        if (r is Map) {
          final rawDistricts = r['districts'];
          final districts = rawDistricts is List
              ? rawDistricts.map((d) => d?.toString() ?? '').where((d) => d.isNotEmpty).toList()
              : const <String>[];
          regions.add(
            Region(
              name: r['name']?.toString() ?? '',
              districts: districts,
            ),
          );
        }
      }
    }

    final loadedAmenities = strings('amenities');
    final amenities = loadedAmenities.isNotEmpty
        ? loadedAmenities
        : FilterOptions.defaultAmenities;

    return FilterOptionsModel(
      propertyTypes: strings('propertyTypes'),
      regions: regions,
      readinessStatuses: strings('readinessStatuses'),
      finishings: strings('finishings'),
      amenities: amenities,
    );
  }
}
