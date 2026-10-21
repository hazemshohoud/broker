import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/withdrawal.dart';
import '../cubit/commissions_cubit.dart';
import '../widgets/payout_labels.dart';
import '../widgets/withdraw_sheet.dart';

class CommissionsPage extends StatelessWidget {
  const CommissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CommissionsCubit>()..load(),
      child: const CommissionsView(),
    );
  }
}

class CommissionsView extends StatefulWidget {
  const CommissionsView({super.key});

  @override
  State<CommissionsView> createState() => _CommissionsViewState();
}

class _CommissionsViewState extends State<CommissionsView> {
  /// 0 = سجل العمولات، 1 = طلبات السحب.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: const AppTopHeader(),
        body: BlocBuilder<CommissionsCubit, CommissionsState>(
          builder: (context, state) {
            final cubit = context.read<CommissionsCubit>();
            if (state.status == CommissionsStatus.loading) {
              return const _CommissionsShimmerSkeleton();
            }
            if (state.status == CommissionsStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'حدث خطأ غير متوقع'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: cubit.load,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            final wallet = state.wallet;
            return RefreshIndicator(
              color: AppColors.brand,
              onRefresh: cubit.load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _BalanceHeader(
                      wallet: wallet,
                      onWithdraw: wallet.availableBalance > 0
                          ? () => showWithdrawSheet(context)
                          : null,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _Tabs(
                        selected: _tab,
                        onChanged: (tab) => setState(() => _tab = tab),
                      ),
                    ),
                  ),
                  ..._tab == 0
                      ? _list(
                          wallet.commissions,
                          (c) => _CommissionTile(commission: c),
                          'لسه مفيش عمولات — أول صفقة ليك هتظهر هنا',
                        )
                      : _list(
                          wallet.withdrawals,
                          (w) => _WithdrawalTile(withdrawal: w),
                          'مفيش طلبات سحب لحد دلوقتي',
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _list<T>(
    List<T> items,
    Widget Function(T) itemBuilder,
    String emptyMessage,
  ) {
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _EmptyState(message: emptyMessage),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => itemBuilder(items[index]),
        ),
      ),
    ];
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.wallet, required this.onWithdraw});

  final Wallet wallet;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.brandDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الرصيد المتاح للسحب',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'محفظة نشطة',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.brandDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${Formatters.number(wallet.availableBalance)} جنيه',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'قيد الاعتماد',
                        value: wallet.pendingCommissions,
                        icon: IconsaxPlusLinear.clock,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        label: 'تم سحبه',
                        value: wallet.withdrawnTotal,
                        icon: IconsaxPlusLinear.tick_circle,
                      ),
                    ),
                  ],
                ),
                if (wallet.reservedTotal > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          IconsaxPlusLinear.info_circle,
                          size: 16,
                          color: Color(0xFFC2410C),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'طلبات سحب قيد التنفيذ: ${Formatters.number(wallet.reservedTotal)} جنيه',
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFC2410C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(
                    IconsaxPlusBold.card_receive,
                    size: 20,
                  ),
                  label: const Text('سحب العمولة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: AppColors.primaryDark,
                    disabledBackgroundColor: AppColors.borderLight,
                    disabledForegroundColor: AppColors.textSecondary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
        ),
      );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final double value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${Formatters.number(value)} جنيه',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'سجل العمولات',
              isSelected: selected == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'طلبات السحب',
              isSelected: selected == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF111111) : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 84 : 0,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF111111) : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}


class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;
  final (String, Color) badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (label, color) = badge;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${Formatters.number(amount)} جنيه',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommissionTile extends StatelessWidget {
  const _CommissionTile({required this.commission});

  final Commission commission;

  @override
  Widget build(BuildContext context) {
    final details = commission.details;
    return _HistoryTile(
      icon: IconsaxPlusLinear.building,
      title: commission.title,
      subtitle: [
        if (details != null && details.isNotEmpty) details,
        Formatters.date(commission.createdAt),
      ].join(' · '),
      amount: commission.amount,
      badge: commission.status.badge,
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile({required this.withdrawal});

  final Withdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    return _HistoryTile(
      icon: withdrawal.method.type.icon,
      title: '${withdrawal.method.type.label} · ${withdrawal.method.number}',
      subtitle: Formatters.date(withdrawal.createdAt),
      amount: withdrawal.amount,
      badge: withdrawal.status.badge,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconsaxPlusLinear.receipt_1,
                size: 44,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommissionsShimmerSkeleton extends StatelessWidget {
  const _CommissionsShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Balance card
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 90, height: 14, borderRadius: 6),
                SizedBox(height: 10),
                ShimmerBox(width: 150, height: 28, borderRadius: 8),
                Spacer(),
                ShimmerBox(width: double.infinity, height: 44, borderRadius: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppShimmer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 120, height: 18, borderRadius: 6),
              ShimmerBox(width: 50, height: 14, borderRadius: 6),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: AppShimmer(
                child: Row(
                  children: [
                    const ShimmerBox(width: 44, height: 44, borderRadius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          ShimmerBox(width: 140, height: 14, borderRadius: 6),
                          SizedBox(height: 6),
                          ShimmerBox(width: 80, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 60, height: 18, borderRadius: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
