import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/admin_withdrawal.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminWithdrawalsPage extends StatefulWidget {
  const AdminWithdrawalsPage({super.key});

  @override
  State<AdminWithdrawalsPage> createState() => _AdminWithdrawalsPageState();
}

class _AdminWithdrawalsPageState extends State<AdminWithdrawalsPage> {
  int _tab = 0; // 0 = قيد الانتظار, 1 = تم التحويل, 2 = مرفوض, 3 = الكل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_right_3, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'طلبات سحب العمولات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final allWithdrawals = state.withdrawals;

          final filtered = allWithdrawals.where((w) {
            if (_tab == 0 && !w.isPending) return false;
            if (_tab == 1 && !w.isCompleted) return false;
            if (_tab == 2 && !w.isRejected) return false;
            return true;
          }).toList();

          return Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text('معلقة (${allWithdrawals.where((w) => w.isPending).length})'),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('محولة (${allWithdrawals.where((w) => w.isCompleted).length})'),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text('مرفوضة (${allWithdrawals.where((w) => w.isRejected).length})'),
                    ),
                    ButtonSegment(
                      value: 3,
                      label: Text('الكل (${allWithdrawals.length})'),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (val) => setState(() => _tab = val.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.brand,
                    selectedForegroundColor: AppColors.primaryDark,
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: () => cubit.loadWithdrawals(),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusLinear.receipt_1, size: 48, color: AppColors.textTertiary),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد طلبات سحب في هذا القسم',
                                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final broker = state.registrations
                                .where((r) => r.id == item.brokerId)
                                .firstOrNull;

                            return _WithdrawalCard(
                              withdrawal: item,
                              brokerName: broker?.fullName,
                              brokerPhone: broker?.phone,
                              onMarkCompleted: () => cubit.updateWithdrawalStatus(item.id, 'completed'),
                              onReject: () => cubit.updateWithdrawalStatus(item.id, 'rejected'),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  const _WithdrawalCard({
    required this.withdrawal,
    required this.onMarkCompleted,
    required this.onReject,
    this.brokerName,
    this.brokerPhone,
  });

  final AdminWithdrawal withdrawal;
  final String? brokerName;
  final String? brokerPhone;
  final VoidCallback onMarkCompleted;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final w = withdrawal;
    final isPending = w.isPending;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.brandDark.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  w.methodType == 'instapay' ? IconsaxPlusBold.bank : IconsaxPlusBold.wallet_1,
                  color: AppColors.brandDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.price(w.amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      brokerName != null ? 'الوسيط: $brokerName' : 'معرف الوسيط: ${w.brokerId.substring(0, 8)}...',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(w.status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // Payout details
          Row(
            children: [
              Text(
                'طريقة الاستلام: ${w.methodType == 'instapay' ? 'إنستاباي' : 'محفظة إلكترونية'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              if (w.methodNumber.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${w.methodNumber})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'تاريخ الطلب: ${Formatters.date(w.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),

          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onMarkCompleted,
                    icon: const Icon(IconsaxPlusBold.tick_circle, size: 18),
                    label: const Text('تأكيد التحويل للوسيط'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.favorite,
                    side: const BorderSide(color: Color(0xFFFECDCA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('رفض'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'completed') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'تم التحويل',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brandDark),
        ),
      );
    }
    if (status == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'مرفوض',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB42318)),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: const Text(
        'قيد التنفيذ',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFC2410C)),
      ),
    );
  }
}
