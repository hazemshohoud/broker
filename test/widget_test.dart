import 'package:broker/core/error/failures.dart';
import 'package:broker/features/home/domain/entities/compound.dart';
import 'package:broker/features/home/domain/entities/compound_filter.dart';
import 'package:broker/features/home/domain/entities/developer.dart';
import 'package:broker/features/home/domain/entities/filter_options.dart';
import 'package:broker/features/home/domain/entities/offer.dart';
import 'package:broker/features/home/domain/repositories/home_repository.dart';
import 'package:broker/features/home/domain/usecases/get_compounds.dart';
import 'package:broker/features/home/domain/usecases/get_developers.dart';
import 'package:broker/features/home/domain/usecases/get_filter_options.dart';
import 'package:broker/features/home/domain/usecases/get_offers.dart';
import 'package:broker/features/home/presentation/cubit/home_cubit.dart';
import 'package:broker/features/home/presentation/pages/home_page.dart';
import 'package:broker/core/widgets/whatsapp_logo.dart';
import 'package:broker/features/home/presentation/widgets/filter_button.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.failure});

  final Failure? failure;

  @override
  Future<Either<Failure, List<Developer>>> getDevelopers() async => Right([
    for (final name in ['SODIC', 'HYDE PARK', 'MOUNTAIN VIEW', 'ORA', 'MODON'])
      Developer(id: name, name: name),
  ]);

  @override
  Future<Either<Failure, List<Offer>>> getOffers() async => const Right([
    Offer(id: 'o1', title: 'عروض ناوي حصرية'),
    Offer(id: 'o2', title: 'Waterway Launching Soon'),
  ]);

  @override
  Future<Either<Failure, List<Compound>>> getCompounds() async {
    if (failure != null) return Left(failure!);
    return const Right([
      Compound(
        id: 'c1',
        name: 'وان هايد بارك',
        location: 'الحي الأول، شرق النيل',
        developerName: 'Hyde Park',
        developerStartPrice: 6870000,
        commission: 171750,
        propertyTypes: ['شقة', 'فيلا', 'دوبلكس'],
        phone: '+201000000000',
        region: 'شرق النيل',
        district: 'الحي الأول',
        readiness: 'جاهز',
        finishing: 'تشطيب كامل',
      ),
    ]);
  }

  @override
  Future<Either<Failure, FilterOptions>> getFilterOptions() async =>
      const Right(
        FilterOptions(
          propertyTypes: ['شقة', 'فيلا'],
          regions: [
            Region(name: 'شرق النيل', districts: ['الحي الأول']),
          ],
          readinessStatuses: ['جاهز', 'تحت الإنشاء'],
          finishings: ['تشطيب كامل'],
        ),
      );
}

HomeCubit _cubit(HomeRepository repository) => HomeCubit(
  getDevelopers: GetDevelopers(repository),
  getOffers: GetOffers(repository),
  getCompounds: GetCompounds(repository),
  getFilterOptions: GetFilterOptions(repository),
);

Compound _compound(
  String id, {
  required double price,
  required double commission,
  List<String> types = const ['شقة'],
  String? region,
  String? district,
  String? readiness,
  String? finishing,
}) => Compound(
  id: id,
  name: id,
  location: '',
  developerName: '',
  developerStartPrice: price,
  commission: commission,
  propertyTypes: types,
  region: region,
  district: district,
  readiness: readiness,
  finishing: finishing,
);

void main() {
  group('HomeCubit', () {
    test('emits success with all sections loaded', () async {
      final cubit = _cubit(_FakeHomeRepository());
      await cubit.load();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.developers, hasLength(5));
      expect(cubit.state.offers, hasLength(2));
      expect(cubit.state.compounds, hasLength(1));
    });

    test('emits failure when any section fails', () async {
      final cubit = _cubit(
        _FakeHomeRepository(failure: const ServerFailure('خطأ')),
      );
      await cubit.load();

      expect(cubit.state.status, HomeStatus.failure);
      expect(cubit.state.errorMessage, 'خطأ');
    });

    test('loads filter options and applies/clears filters', () async {
      final cubit = _cubit(_FakeHomeRepository());
      await cubit.load();
      expect(cubit.state.filterOptions.regions.single.name, 'شرق النيل');

      cubit.applyFilter(const CompoundFilter(readiness: 'تحت الإنشاء'));
      expect(cubit.state.visibleCompounds, isEmpty);
      expect(cubit.state.filter.activeCount, 1);

      cubit.clearFilter();
      expect(cubit.state.visibleCompounds, hasLength(1));
    });
  });

  group('CompoundFilter', () {
    final compounds = [
      _compound(
        'a',
        price: 5e6,
        commission: 100e3,
        types: ['شقة', 'روف'],
        region: 'شرق النيل',
        district: 'الحي الأول',
        readiness: 'جاهز',
        finishing: 'تشطيب كامل',
      ),
      _compound(
        'b',
        price: 9e6,
        commission: 300e3,
        types: ['فيلا'],
        region: 'بني سويف',
        district: 'الكورنيش',
        readiness: 'تحت الإنشاء',
        finishing: 'عضم',
      ),
      _compound(
        'c',
        price: 7e6,
        commission: 200e3,
        types: ['أرض'],
        region: 'مراكز',
        district: 'ببا',
        readiness: 'جاهز',
        finishing: 'نصف تشطيب',
      ),
    ];

    List<String> ids(CompoundFilter f) => [
      for (final c in f.apply(compounds)) c.id,
    ];

    test('empty filter returns everything in original order', () {
      expect(ids(const CompoundFilter()), ['a', 'b', 'c']);
      expect(const CompoundFilter().isEmpty, isTrue);
    });

    test('type matches any overlap', () {
      expect(ids(const CompoundFilter(propertyTypes: {'روف', 'أرض'})), [
        'a',
        'c',
      ]);
    });

    test('region and district', () {
      expect(ids(const CompoundFilter(region: 'مراكز')), ['c']);
      expect(
        ids(
          const CompoundFilter(region: 'شرق النيل', districts: {'الحي الثالث'}),
        ),
        isEmpty,
      );
    });

    test('readiness, finishing, price and commission ranges', () {
      expect(ids(const CompoundFilter(readiness: 'جاهز')), ['a', 'c']);
      expect(ids(const CompoundFilter(finishing: 'عضم')), ['b']);
      expect(ids(const CompoundFilter(price: NumRange(6e6, 10e6))), ['b', 'c']);
      expect(ids(const CompoundFilter(commission: NumRange(150e3, 250e3))), [
        'c',
      ]);
    });

    test('sorting', () {
      expect(ids(const CompoundFilter(sort: CompoundSort.priceLowToHigh)), [
        'a',
        'c',
        'b',
      ]);
      expect(ids(const CompoundFilter(sort: CompoundSort.priceHighToLow)), [
        'b',
        'c',
        'a',
      ]);
      expect(ids(const CompoundFilter(sort: CompoundSort.highestCommission)), [
        'b',
        'c',
        'a',
      ]);
    });

    test('copyWith can reset nullable fields', () {
      const filter = CompoundFilter(region: 'مراكز', readiness: 'جاهز');
      final reset = filter.copyWith(region: () => null);
      expect(reset.region, isNull);
      expect(reset.readiness, 'جاهز');
    });
  });

  testWidgets('HomeView renders all sections on a phone screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = _cubit(_FakeHomeRepository());
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: BlocProvider.value(value: cubit, child: const HomeView()),
      ),
    );

    expect(find.text('المشروعات الجديدة والعروض'), findsOneWidget);
    expect(find.text('وان هايد بارك'), findsOneWidget);
    expect(find.byType(WhatsAppLogo), findsOneWidget);
    expect(find.byIcon(Icons.phone_rounded), findsOneWidget);
    expect(find.text('العمولة'), findsOneWidget);
    expect(find.text('171,750 جم'), findsOneWidget);
    expect(find.text('غير متوفر'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(FilterButton));
    await tester.pumpAndSettle();
    expect(find.text('الفلتر'), findsOneWidget);
    expect(find.text('حالة العقار'), findsOneWidget);
    expect(find.text('عرض النتائج (1)'), findsOneWidget);

    await tester.tap(find.text('تحت الإنشاء'));
    await tester.pump();
    expect(find.text('عرض النتائج (0)'), findsOneWidget);

    await tester.tap(find.text('عرض النتائج (0)'));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد نتائج مطابقة للفلتر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeView renders responsively on a compact small phone (320x568)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final cubit = _cubit(_FakeHomeRepository());
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: BlocProvider.value(value: cubit, child: const HomeView()),
      ),
    );

    expect(find.text('المشروعات الجديدة والعروض'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('وان هايد بارك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeView renders responsively on a tablet screen (800x1280)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1280) * 1.5;
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);

    final cubit = _cubit(_FakeHomeRepository());
    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: BlocProvider.value(value: cubit, child: const HomeView()),
      ),
    );

    expect(find.text('المشروعات الجديدة والعروض'), findsOneWidget);
    expect(find.text('وان هايد بارك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
