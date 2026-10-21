import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../../domain/entities/broker_client.dart';
import '../../../home/presentation/widgets/home_search_bar.dart';
import '../cubit/clients_cubit.dart';
import '../widgets/add_client_sheet.dart';
import '../widgets/client_card.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClientsCubit>()..load(),
      child: const ClientsView(),
    );
  }
}

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  Future<void> _confirmDelete(BuildContext context, BrokerClient client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العميل'),
        content: Text('متأكد إنك عايز تحذف "${client.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ClientsCubit>().deleteClient(client.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: const AppTopHeader(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: BlocBuilder<ClientsCubit, ClientsState>(
          buildWhen: (a, b) => a.status != b.status,
          builder: (context, state) {
            if (state.status != ClientsStatus.success) {
              return const SizedBox.shrink();
            }
            return _AddClientFab(onTap: () => AddClientSheet.show(context));
          },
        ),
        body: Column(
          children: [
            // شريط البحث بنفس فورم وتصميم شريط البحث في الهوم
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: BlocBuilder<ClientsCubit, ClientsState>(
                buildWhen: (a, b) => a.searchQuery != b.searchQuery,
                builder: (context, state) {
                  return HomeSearchBar(
                    hintText: 'ابحث بالاسم، رقم الهاتف، أو المشروع...',
                    initialValue: state.searchQuery,
                    onChanged: (val) =>
                        context.read<ClientsCubit>().updateSearchQuery(val),
                  );
                },
              ),
            ),

            // محتوى قائمة العملاء من قاعدة البيانات
            Expanded(
              child: BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, state) {
                  if (state.status == ClientsStatus.loading) {
                    return const _ClientsShimmerSkeleton();
                  }
                  if (state.status == ClientsStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'حدث خطأ غير متوقع'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                context.read<ClientsCubit>().load(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  // قاعدة البيانات خالية تماماً من العملاء
                  if (state.clients.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.brand,
                      onRefresh: context.read<ClientsCubit>().load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.45,
                            child: const _EmptyClients(),
                          ),
                        ],
                      ),
                    );
                  }

                  final displayedClients = state.filteredClients;

                  // لا توجد نتائج مطابقة لنص البحث الحالي
                  if (displayedClients.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.brand,
                      onRefresh: context.read<ClientsCubit>().load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.45,
                            child: _NoSearchResults(
                              query: state.searchQuery,
                              onClear: () =>
                                  context.read<ClientsCubit>().clearSearch(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.brand,
                    onRefresh: context.read<ClientsCubit>().load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
                      itemCount: displayedClients.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => ClientCard(
                        client: displayedClients[index],
                        onDelete: () =>
                            _confirmDelete(context, displayedClients[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زرار عائم أسود في نص الشاشة من تحت — يطفو بأناقة فوق البوتوم بار مباشرة.
class _AddClientFab extends StatelessWidget {
  const _AddClientFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final extraBottom = bottomInset > 0 ? 62.0 : 78.0;

    return Padding(
      padding: EdgeInsets.only(bottom: extraBottom),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  IconsaxPlusBold.add_circle,
                  size: 22,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'إضافة عميل جديد',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _EmptyClients extends StatelessWidget {
  const _EmptyClients();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconsaxPlusLinear.people,
              size: 44,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا يوجد عملاء، قم بإضافة أول عميل',
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsShimmerSkeleton extends StatelessWidget {
  const _ClientsShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 130, height: 16, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const ShimmerBox(width: double.infinity, height: 32, borderRadius: 8),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: ShimmerBox(height: 38, borderRadius: 10)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 38, borderRadius: 10)),
                  SizedBox(width: 8),
                  ShimmerBox(width: 38, height: 38, borderRadius: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة عند عدم وجود نتائج بحث مطابقة
class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.query,
    required this.onClear,
  });

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxPlusLinear.search_status,
                size: 38,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد نتائج مطابقة لـ "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'تأكد من كتابة الاسم أو رقم الهاتف أو اسم المشروع بشكل صحيح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'مسح البحث وعرض كل العملاء',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

