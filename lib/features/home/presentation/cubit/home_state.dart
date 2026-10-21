part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.developers = const [],
    this.offers = const [],
    this.compounds = const [],
    this.filterOptions = const FilterOptions(),
    this.filter = const CompoundFilter(),
    this.searchQuery = '',
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Developer> developers;
  final List<Offer> offers;
  final List<Compound> compounds;
  final FilterOptions filterOptions;
  final CompoundFilter filter;
  final String searchQuery;
  final String? errorMessage;

  /// المشاريع المخصصة لقسم المشروعات الجديدة
  List<Compound> get projectCompounds =>
      compounds.where((c) => c.isProject).toList();

  /// الكمبوندات بعد تطبيق الفلتر والبحث والترتيب (تستبعد المشاريع إذا لم يكن هناك بحث نشط).
  List<Compound> get visibleCompounds {
    var list = filter.apply(compounds);
    final q = searchQuery.trim();
    if (q.isNotEmpty) {
      list = list.where((c) {
        return ArabicSearchHelper.matchesQuery(
          query: q,
          targets: [
            c.name,
            c.developerName,
            c.location,
            c.region,
            c.district,
            c.propertyTypes.join(' '),
            c.readiness,
            c.finishing,
          ],
        );
      }).toList();
    } else {
      // إظهار العقارات العادية فقط في القائمة الرئيسية (المشاريع تظهر في قسم المشاريع بالأعلى)
      list = list.where((c) => !c.isProject).toList();
    }
    return list;
  }

  HomeState copyWith({
    HomeStatus? status,
    List<Developer>? developers,
    List<Offer>? offers,
    List<Compound>? compounds,
    FilterOptions? filterOptions,
    CompoundFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      developers: developers ?? this.developers,
      offers: offers ?? this.offers,
      compounds: compounds ?? this.compounds,
      filterOptions: filterOptions ?? this.filterOptions,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    developers,
    offers,
    compounds,
    filterOptions,
    filter,
    searchQuery,
    errorMessage,
  ];
}
