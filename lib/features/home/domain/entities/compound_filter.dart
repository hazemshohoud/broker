import 'package:equatable/equatable.dart';

import 'compound.dart';

enum CompoundSort {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  highestCommission,
}

class NumRange extends Equatable {
  const NumRange(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value >= (min - 1e-4) && value <= (max + 1e-4);

  @override
  List<Object?> get props => [min, max];
}

/// الفلتر اللي اختاره المستخدم. القيمة الفاضية/null معناها "الكل".
class CompoundFilter extends Equatable {
  const CompoundFilter({
    this.propertyTypes = const {},
    this.region,
    this.districts = const {},
    this.readiness,
    this.finishing,
    this.price,
    this.commission,
    this.sort = CompoundSort.recommended,
  });

  final Set<String> propertyTypes;
  final String? region;
  final Set<String> districts;
  final String? readiness;
  final String? finishing;
  final NumRange? price;
  final NumRange? commission;
  final CompoundSort sort;

  int get activeCount => [
    propertyTypes.isNotEmpty,
    region != null,
    readiness != null,
    finishing != null,
    price != null,
    commission != null,
    sort != CompoundSort.recommended,
  ].where((active) => active).length;

  bool get isEmpty => activeCount == 0;

  bool matches(Compound compound) {
    if (propertyTypes.isNotEmpty &&
        !compound.propertyTypes.any((t) => propertyTypes.contains(t.trim()))) {
      return false;
    }
    if (region != null && (compound.region?.trim() != region!.trim())) {
      return false;
    }
    if (districts.isNotEmpty &&
        (compound.district == null || !districts.contains(compound.district!.trim()))) {
      return false;
    }
    if (readiness != null && (compound.readiness?.trim() != readiness!.trim())) {
      return false;
    }
    if (finishing != null && (compound.finishing?.trim() != finishing!.trim())) {
      return false;
    }
    if (price != null && !price!.contains(compound.developerStartPrice)) {
      return false;
    }
    if (commission != null && !commission!.contains(compound.commission)) {
      return false;
    }
    return true;
  }

  List<Compound> apply(List<Compound> compounds) {
    final result = compounds.where(matches).toList();
    switch (sort) {
      case CompoundSort.recommended:
        break;
      case CompoundSort.priceLowToHigh:
        result.sort(
          (a, b) => a.developerStartPrice.compareTo(b.developerStartPrice),
        );
      case CompoundSort.priceHighToLow:
        result.sort(
          (a, b) => b.developerStartPrice.compareTo(a.developerStartPrice),
        );
      case CompoundSort.highestCommission:
        result.sort((a, b) => b.commission.compareTo(a.commission));
    }
    return result;
  }

  /// الـ nullable fields بتتبعت كـ function عشان نقدر نرجعها null.
  CompoundFilter copyWith({
    Set<String>? propertyTypes,
    String? Function()? region,
    Set<String>? districts,
    String? Function()? readiness,
    String? Function()? finishing,
    NumRange? Function()? price,
    NumRange? Function()? commission,
    CompoundSort? sort,
  }) {
    return CompoundFilter(
      propertyTypes: propertyTypes ?? this.propertyTypes,
      region: region != null ? region() : this.region,
      districts: districts ?? this.districts,
      readiness: readiness != null ? readiness() : this.readiness,
      finishing: finishing != null ? finishing() : this.finishing,
      price: price != null ? price() : this.price,
      commission: commission != null ? commission() : this.commission,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [
    propertyTypes,
    region,
    districts,
    readiness,
    finishing,
    price,
    commission,
    sort,
  ];
}
