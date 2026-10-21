import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/launcher.dart';
import '../cubit/home_cubit.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../widgets/compound_card.dart';
import '../widgets/compound_filter_sheet.dart';
import '../widgets/developers_list.dart';
import '../widgets/filter_button.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_shimmer_skeleton.dart';
import '../widgets/offers_carousel.dart';
import '../widgets/section_header.dart';
import 'compound_details_page.dart';
import 'developers_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _offersScrollController = ScrollController();
  final GlobalKey _compoundsSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    _offersScrollController.dispose();
    super.dispose();
  }

  void _scrollOffersCarousel() {
    if (!_offersScrollController.hasClients) return;
    final max = _offersScrollController.position.maxScrollExtent;
    final current = _offersScrollController.offset;
    if (max <= 0) return;

    if (current >= max - 15) {
      _offersScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final target = (current + 250.0).clamp(0.0, max);
      _offersScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: const AppTopHeader(),
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: AppColors.brand,
                onRefresh: () => context.read<HomeCubit>().load(forceRefresh: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      sliver: SliverToBoxAdapter(
                        child: HomeSearchBar(
                          initialValue: state.searchQuery,
                          onChanged: context.read<HomeCubit>().search,
                        ),
                      ),
                    ),
                    ..._buildBody(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, HomeState state) {
    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const [
          SliverToBoxAdapter(
            child: HomeShimmerSkeleton(),
          ),
        ];
      case HomeStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorView(
              message: state.errorMessage ?? 'حدث خطأ غير متوقع',
              onRetry: context.read<HomeCubit>().load,
            ),
          ),
        ];
      case HomeStatus.success:
        final visibleCompounds = state.visibleCompounds;
        return [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'شركات التطوير العقاري',
                actionLabel: 'اظهر الكل',
                onActionTap: () => DevelopersPage.open(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: DevelopersList(developers: state.developers),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'المشروعات الجديدة والعروض',
                actionLabel: 'اظهر الكل',
                onActionTap: _scrollOffersCarousel,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: OffersCarousel(
              scrollController: _offersScrollController,
              projectCompounds: state.projectCompounds,
              offers: state.offers,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 28, bottom: 14),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                key: _compoundsSectionKey,
                title: 'كمبوندات في مصر',
                trailing: FilterButton(
                  activeCount: state.filter.activeCount,
                  onTap: () => _openFilter(context, state),
                ),
              ),
            ),
          ),
          if (visibleCompounds.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyResults(
                isSearching: state.searchQuery.isNotEmpty,
                hasFilter: !state.filter.isEmpty,
                onClear: () {
                  context.read<HomeCubit>().clearFilter();
                  context.read<HomeCubit>().search('');
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
            sliver: SliverList.separated(
              itemCount: visibleCompounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final compound = visibleCompounds[index];
                final phone = compound.phone;
                final whatsapp = compound.whatsapp ?? compound.phone;
                return CompoundCard(
                  compound: compound,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompoundDetailsPage(compound: compound),
                    ),
                  ),
                  onCallTap: phone == null ? null : () => Launcher.call(phone),
                  onWhatsAppTap: whatsapp == null ? null : () => Launcher.whatsapp(whatsapp),
                );
              },
            ),
          ),
        ];
    }
  }

  Future<void> _openFilter(BuildContext context, HomeState state) async {
    final cubit = context.read<HomeCubit>();
    final filter = await showCompoundFilterSheet(
      context,
      options: state.filterOptions,
      compounds: state.compounds,
      initial: state.filter,
    );
    if (filter != null) cubit.applyFilter(filter);
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.isSearching,
    required this.hasFilter,
    required this.onClear,
  });

  final bool isSearching;
  final bool hasFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final String message;
    if (isSearching && hasFilter) {
      message = 'لا توجد نتائج مطابقة للبحث والفلاتر المحددة';
    } else if (isSearching) {
      message = 'لا توجد نتائج مطابقة لبحثك';
    } else {
      message = 'لا توجد نتائج مطابقة للفلتر';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: onClear,
            child: const Text('إعادة ضبط البحث والفلاتر'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
