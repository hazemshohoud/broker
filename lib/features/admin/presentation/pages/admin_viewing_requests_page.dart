import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/launcher.dart';
import '../../domain/entities/admin_viewing_request.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminViewingRequestsPage extends StatefulWidget {
  const AdminViewingRequestsPage({super.key});

  @override
  State<AdminViewingRequestsPage> createState() => _AdminViewingRequestsPageState();
}

class _AdminViewingRequestsPageState extends State<AdminViewingRequestsPage> {
  String _selectedFilter = 'all'; // all, pending, approved, completed, cancelled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadViewingRequests();
    });
  }

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
          'طلبات المعاينة',
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
            onPressed: () => context.read<AdminCubit>().loadViewingRequests(),
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
          final allRequests = state.viewingRequests;
          final filtered = allRequests.where((req) {
            if (_selectedFilter == 'pending') return req.isPending;
            if (_selectedFilter == 'approved') return req.isApproved;
            if (_selectedFilter == 'completed') return req.isCompleted;
            if (_selectedFilter == 'cancelled') return req.isCancelled;
            return true;
          }).toList();

          final pendingCount = allRequests.where((r) => r.isPending).length;

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
                        label: 'الكل (${allRequests.length})',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'قيد المراجعة ($pendingCount)',
                        isSelected: _selectedFilter == 'pending',
                        badgeColor: pendingCount > 0 ? AppColors.warning : null,
                        onTap: () => setState(() => _selectedFilter = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'معتمدة (${allRequests.where((r) => r.isApproved).length})',
                        isSelected: _selectedFilter == 'approved',
                        onTap: () => setState(() => _selectedFilter = 'approved'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'مكتملة (${allRequests.where((r) => r.isCompleted).length})',
                        isSelected: _selectedFilter == 'completed',
                        onTap: () => setState(() => _selectedFilter = 'completed'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'ملغاة (${allRequests.where((r) => r.isCancelled).length})',
                        isSelected: _selectedFilter == 'cancelled',
                        onTap: () => setState(() => _selectedFilter = 'cancelled'),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Request list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconsaxPlusLinear.calendar_1, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'pending'
                                  ? 'لا توجد طلبات معاينة جديدة قيد الانتظار'
                                  : 'لا توجد طلبات معاينة مسجلة',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.brand,
                        onRefresh: () => context.read<AdminCubit>().loadViewingRequests(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final request = filtered[index];
                            return _ViewingRequestCard(request: request);
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

class _ViewingRequestCard extends StatelessWidget {
  const _ViewingRequestCard({required this.request});

  final AdminViewingRequest request;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');

    // Status badge data
    Color statusBg;
    Color statusFg;
    String statusLabel;
    IconData statusIcon;

    if (request.isPending) {
      statusBg = const Color(0xFFFFF7ED);
      statusFg = const Color(0xFFC2410C);
      statusLabel = 'قيد المراجعة';
      statusIcon = IconsaxPlusBold.clock;
    } else if (request.isApproved) {
      statusBg = const Color(0xFFECFDF5);
      statusFg = const Color(0xFF047857);
      statusLabel = 'معتمدة / مؤكدة';
      statusIcon = IconsaxPlusBold.tick_circle;
    } else if (request.isCompleted) {
      statusBg = const Color(0xFFEFF6FF);
      statusFg = const Color(0xFF1D4ED8);
      statusLabel = 'تمت المعاينة';
      statusIcon = IconsaxPlusBold.verify;
    } else {
      statusBg = const Color(0xFFFEF2F2);
      statusFg = const Color(0xFFB91C1C);
      statusLabel = 'ملغاة';
      statusIcon = IconsaxPlusBold.close_circle;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.isPending ? AppColors.brand.withValues(alpha: 0.5) : AppColors.border,
          width: request.isPending ? 1.5 : 1,
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
          // Header: Compound Name & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(IconsaxPlusBold.building_4, size: 20, color: AppColors.brandDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.compoundName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (request.developerName != null && request.developerName!.isNotEmpty)
                      Text(
                        request.developerName!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),

          // Client Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(IconsaxPlusLinear.user, size: 18, color: AppColors.brandDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('العميل', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        request.clientName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        request.clientPhone,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(IconsaxPlusBold.call, size: 18, color: AppColors.brandDark),
                  onPressed: () => Launcher.call(request.clientPhone),
                  tooltip: 'اتصال بالعميل',
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF25D366)),
                  onPressed: () => Launcher.whatsapp(request.clientPhone),
                  tooltip: 'واتساب العميل',
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Broker Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(IconsaxPlusLinear.profile_2user, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الوسيط مقدم الطلب', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        request.brokerName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      if (request.brokerPhone != null && request.brokerPhone!.isNotEmpty)
                        Text(
                          request.brokerPhone!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (request.brokerPhone != null && request.brokerPhone!.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(IconsaxPlusBold.call, size: 18, color: AppColors.primary),
                    onPressed: () => Launcher.call(request.brokerPhone!),
                    tooltip: 'اتصال بالوسيط',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF25D366)),
                    onPressed: () => Launcher.whatsapp(request.brokerPhone!),
                    tooltip: 'واتساب الوسيط',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Viewing Date & Notes
          Row(
            children: [
              const Icon(IconsaxPlusLinear.calendar_tick, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'موعد المعاينة المطلوب: ${dateFormat.format(request.viewingDate)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),

          if (request.notes != null && request.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(IconsaxPlusLinear.note_1, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ملاحظات: ${request.notes}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Status Action Buttons
          if (request.isPending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AdminCubit>().updateViewingRequestStatus(request.id, 'approved'),
                    icon: const Icon(IconsaxPlusBold.tick_circle, size: 16, color: AppColors.primaryDark),
                    label: const Text('اعتماد وتأكيد'),
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
                  onPressed: () => context.read<AdminCubit>().updateViewingRequestStatus(request.id, 'cancelled'),
                  icon: const Icon(IconsaxPlusLinear.close_circle, size: 16, color: AppColors.error),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ],
            ),
          ] else if (request.isApproved) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AdminCubit>().updateViewingRequestStatus(request.id, 'completed'),
                    icon: const Icon(IconsaxPlusBold.verify, size: 16, color: Colors.white),
                    label: const Text('تمت المعاينة بنجاح'),
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
                OutlinedButton.icon(
                  onPressed: () => context.read<AdminCubit>().updateViewingRequestStatus(request.id, 'cancelled'),
                  icon: const Icon(IconsaxPlusLinear.close_circle, size: 16, color: AppColors.error),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
