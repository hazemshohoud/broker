import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/launcher.dart';
import '../../domain/entities/admin_commission.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminCommissionsPage extends StatefulWidget {
  const AdminCommissionsPage({super.key});

  @override
  State<AdminCommissionsPage> createState() => _AdminCommissionsPageState();
}

class _AdminCommissionsPageState extends State<AdminCommissionsPage> {
  String _selectedFilter = 'all'; // all, pending, approved, completed, rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadCommissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0);

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
          'إدارة واعتماد العمولات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.refresh, color: AppColors.textPrimary),
            tooltip: 'تحديث',
            onPressed: () => context.read<AdminCubit>().loadCommissions(),
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final allCommissions = state.commissions;
          final filtered = allCommissions.where((c) {
            if (_selectedFilter == 'pending') return c.isPending;
            if (_selectedFilter == 'approved') return c.isApproved;
            if (_selectedFilter == 'completed') return c.isCompleted;
            if (_selectedFilter == 'rejected') return c.isRejected;
            return true;
          }).toList();

          final pendingCount = allCommissions.where((c) => c.isPending).length;

          return Column(
            children: [
              // Filter Chips Row
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'الكل (${allCommissions.length})',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'قيد الاعتماد ($pendingCount)',
                        isSelected: _selectedFilter == 'pending',
                        badgeColor: pendingCount > 0 ? AppColors.warning : null,
                        onTap: () => setState(() => _selectedFilter = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'معتمدة (${allCommissions.where((c) => c.isApproved).length})',
                        isSelected: _selectedFilter == 'approved',
                        onTap: () => setState(() => _selectedFilter = 'approved'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'مكتملة الصرف (${allCommissions.where((c) => c.isCompleted).length})',
                        isSelected: _selectedFilter == 'completed',
                        onTap: () => setState(() => _selectedFilter = 'completed'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'مرفوضة (${allCommissions.where((c) => c.isRejected).length})',
                        isSelected: _selectedFilter == 'rejected',
                        onTap: () => setState(() => _selectedFilter = 'rejected'),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Commissions List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconsaxPlusLinear.wallet_3, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'pending'
                                  ? 'لا توجد عمولات قيد الاعتماد حالياً'
                                  : 'لا توجد عمولات مسجلة',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.brand,
                        onRefresh: () => context.read<AdminCubit>().loadCommissions(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final comm = filtered[index];
                            return _CommissionCard(
                              commission: comm,
                              currencyFormatter: currencyFormatter,
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

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            if (badgeColor != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  const _CommissionCard({
    required this.commission,
    required this.currencyFormatter,
  });

  final AdminCommission commission;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');

    Color statusBg;
    Color statusFg;
    String statusLabel;
    IconData statusIcon;

    if (commission.isPending) {
      statusBg = const Color(0xFFFFF7ED);
      statusFg = const Color(0xFFC2410C);
      statusLabel = 'قيد الاعتماد';
      statusIcon = IconsaxPlusBold.clock;
    } else if (commission.isApproved) {
      statusBg = const Color(0xFFECFDF5);
      statusFg = const Color(0xFF047857);
      statusLabel = 'معتمدة';
      statusIcon = IconsaxPlusBold.tick_circle;
    } else if (commission.isCompleted) {
      statusBg = const Color(0xFFEFF6FF);
      statusFg = const Color(0xFF1D4ED8);
      statusLabel = 'تم الصرف';
      statusIcon = IconsaxPlusBold.verify;
    } else {
      statusBg = const Color(0xFFFEF2F2);
      statusFg = const Color(0xFFB91C1C);
      statusLabel = 'مرفوضة';
      statusIcon = IconsaxPlusBold.close_circle;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: commission.isPending ? AppColors.brand.withValues(alpha: 0.5) : AppColors.border,
          width: commission.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Amount & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(IconsaxPlusBold.dollar_circle, size: 22, color: AppColors.brandDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormatter.format(commission.amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandDark,
                      ),
                    ),
                    Text(
                      commission.compoundName ?? commission.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusFg.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusFg),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Broker Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(IconsaxPlusLinear.profile_circle, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الوسيط المستحق', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        commission.brokerName ?? 'وسيط مسجل',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      if (commission.brokerPhone != null && commission.brokerPhone!.isNotEmpty)
                        Text(
                          commission.brokerPhone!,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (commission.brokerPhone != null && commission.brokerPhone!.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(IconsaxPlusBold.call, size: 18, color: AppColors.primary),
                    onPressed: () => Launcher.call(commission.brokerPhone!),
                    tooltip: 'اتصال',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF25D366)),
                    onPressed: () => Launcher.whatsapp(commission.brokerPhone!),
                    tooltip: 'واتساب',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Date
          Row(
            children: [
              const Icon(IconsaxPlusLinear.clock, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'تاريخ التسجيل: ${dateFormat.format(commission.createdAt)}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Admin Action Buttons
          if (commission.isPending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmUpdateStatus(context, 'approved', 'اعتماد العمولة'),
                    icon: const Icon(IconsaxPlusBold.tick_circle, size: 16, color: AppColors.primaryDark),
                    label: const Text('اعتماد العمولة الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.primaryDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmUpdateStatus(context, 'rejected', 'رفض العمولة'),
                  icon: const Icon(IconsaxPlusLinear.close_circle, size: 16, color: AppColors.error),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ],
            ),
          ] else if (commission.isApproved) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmUpdateStatus(context, 'completed', 'تأكيد صرف العمولة'),
                    icon: const Icon(IconsaxPlusBold.verify, size: 16, color: Colors.white),
                    label: const Text('تأكيد الصرف للمستحق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _confirmUpdateStatus(context, 'pending', 'إعادة لقيد الاعتماد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  ),
                  child: const Text('إعادة للانتظار', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmUpdateStatus(BuildContext context, String newStatus, String actionTitle) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(actionTitle),
        content: Text('هل أنت متأكد من تغيير حالة العمولة إلى "$actionTitle"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AdminCubit>().updateCommissionStatus(commission.id, newStatus);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
