import 'package:equatable/equatable.dart';

/// خيارات الفلتر المتاحة — بيتحكم فيها الأدمن من قاعدة البيانات.
class FilterOptions extends Equatable {
  const FilterOptions({
    this.propertyTypes = const [],
    this.regions = const [],
    this.readinessStatuses = const [],
    this.finishings = const [],
  });

  final List<String> propertyTypes;
  final List<Region> regions;
  final List<String> readinessStatuses;
  final List<String> finishings;

  FilterOptions copyWith({
    List<String>? propertyTypes,
    List<Region>? regions,
    List<String>? readinessStatuses,
    List<String>? finishings,
  }) {
    return FilterOptions(
      propertyTypes: propertyTypes ?? this.propertyTypes,
      regions: regions ?? this.regions,
      readinessStatuses: readinessStatuses ?? this.readinessStatuses,
      finishings: finishings ?? this.finishings,
    );
  }

  @override
  List<Object?> get props => [
    propertyTypes,
    regions,
    readinessStatuses,
    finishings,
  ];
}

class Region extends Equatable {
  const Region({required this.name, this.districts = const []});

  final String name;
  final List<String> districts;

  @override
  List<Object?> get props => [name, districts];
}
