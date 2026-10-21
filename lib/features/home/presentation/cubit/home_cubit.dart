import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/compound_filter.dart';
import '../../domain/entities/developer.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/offer.dart';
import '../../domain/usecases/get_compounds.dart';
import '../../domain/usecases/get_developers.dart';
import '../../domain/usecases/get_filter_options.dart';
import '../../domain/usecases/get_offers.dart';
import '../../../../core/utils/arabic_search.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetDevelopers getDevelopers,
    required GetOffers getOffers,
    required GetCompounds getCompounds,
    required GetFilterOptions getFilterOptions,
  }) : _getDevelopers = getDevelopers,
       _getOffers = getOffers,
       _getCompounds = getCompounds,
       _getFilterOptions = getFilterOptions,
       super(const HomeState());

  final GetDevelopers _getDevelopers;
  final GetOffers _getOffers;
  final GetCompounds _getCompounds;
  final GetFilterOptions _getFilterOptions;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        state.status == HomeStatus.success &&
        state.compounds.isNotEmpty) {
      return;
    }
    emit(state.copyWith(status: HomeStatus.loading));

    final (developers, offers, compounds, filterOptions) = await (
      _getDevelopers(const NoParams()),
      _getOffers(const NoParams()),
      _getCompounds(const NoParams()),
      _getFilterOptions(const NoParams()),
    ).wait;

    final failure = [developers, offers, compounds]
        .map((result) => result.fold<Failure?>((f) => f, (_) => null))
        .nonNulls
        .firstOrNull;

    if (failure != null) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeStatus.success,
        developers: developers.getOrElse(() => []),
        offers: offers.getOrElse(() => []),
        compounds: compounds.getOrElse(() => []),
        // الفلتر مش أساسي — لو فشل تحميل خياراته الصفحة تفضل شغالة.
        filterOptions: filterOptions.getOrElse(() => const FilterOptions()),
      ),
    );
  }

  void applyFilter(CompoundFilter filter) =>
      emit(state.copyWith(filter: filter));

  void clearFilter() => emit(state.copyWith(filter: const CompoundFilter()));

  void search(String query) => emit(state.copyWith(searchQuery: query));
}
