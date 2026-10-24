import 'package:equatable/equatable.dart';

/// خيارات الفلتر المتاحة — بيتحكم فيها الأدمن من قاعدة البيانات.
class FilterOptions extends Equatable {
  static const defaultAmenities = [
    'مستشفى',
    'جامعة',
    'مدرسة',
    'نادي',
    'سوبر ماركت',
    'عيادة',
    'صيدلية',
    'جيم',
    'كافيه او مطعم',
    'مساحات خضراء',
  ];

  const FilterOptions({
    this.propertyTypes = const [],
    this.regions = const [],
    this.readinessStatuses = const [],
    this.finishings = const [],
    this.amenities = defaultAmenities,
  });

  final List<String> propertyTypes;
  final List<Region> regions;
  final List<String> readinessStatuses;
  final List<String> finishings;
  final List<String> amenities;

  FilterOptions copyWith({
    List<String>? propertyTypes,
    List<Region>? regions,
    List<String>? readinessStatuses,
    List<String>? finishings,
    List<String>? amenities,
  }) {
    return FilterOptions(
      propertyTypes: propertyTypes ?? this.propertyTypes,
      regions: regions ?? this.regions,
      readinessStatuses: readinessStatuses ?? this.readinessStatuses,
      finishings: finishings ?? this.finishings,
      amenities: amenities ?? this.amenities,
    );
  }

  @override
  List<Object?> get props => [
    propertyTypes,
    regions,
    readinessStatuses,
    finishings,
    amenities,
  ];
}

class Region extends Equatable {
  const Region({required this.name, this.districts = const []});

  final String name;
  final List<String> districts;

  @override
  List<Object?> get props => [name, districts];
}
