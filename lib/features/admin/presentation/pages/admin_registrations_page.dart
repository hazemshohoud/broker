import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/launcher.dart';
import '../../domain/entities/admin_registration.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/admin_grant_commission_sheet.dart';

class AdminRegistrationsPage extends StatefulWidget {
  const AdminRegistrationsPage({super.key});

  @override
  State<AdminRegistrationsPage> createState() => _AdminRegistrationsPageState();
}

class _AdminRegistrationsPageState extends State<AdminRegistrationsPage> {
  int _filterTab = 0; // 0 = قيد الانتظار, 1 = المعتمدين, 2 = الكل
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'توثيق وقبول الوسطاء',
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
          final allRegistrations = state.registrations;

          final filtered = allRegistrations.where((r) {
            if (_filterTab == 0 && !r.isPending) return false;
            if (_filterTab == 1 && !r.isApproved) return false;

            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchName = r.fullName.toLowerCase().contains(query);
              final matchPhone = r.phone.contains(query);
              final matchGov = r.governorate.toLowerCase().contains(query);
              if (!matchName && !matchPhone && !matchGov) return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'البحث بالاسم، رقم الهاتف أو المحافظة...',
                        prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<int>(
                      segments: [
                        ButtonSegment(
                          value: 0,
                          label: Text('قيد المراجعة (${allRegistrations.where((r) => r.isPending).length})'),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('المعتمدين (${allRegistrations.where((r) => r.isApproved).length})'),
                        ),
                        ButtonSegment(
                          value: 2,
                          label: Text('الكل (${allRegistrations.length})'),
                        ),
                      ],
                      selected: {_filterTab},
                      onSelectionChanged: (val) => setState(() => _filterTab = val.first),
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.brand,
                        selectedForegroundColor: AppColors.primaryDark,
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: () => cubit.loadRegistrations(),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusLinear.profile_tick, size: 48, color: AppColors.textTertiary),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد طلبات تسجيل مطابقة',
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
                            return _RegistrationCard(
                              registration: item,
                              onApprove: () => cubit.updateRegistrationStatus(item.id, 'approved'),
                              onReject: () => cubit.updateRegistrationStatus(item.id, 'rejected'),
                              onDelete: () => _confirmDelete(context, item, cubit),
                              onGrantCommission: () => AdminGrantCommissionSheet.show(
                                context,
                                cubit: cubit,
                                registrations: allRegistrations,
                                preselectedBrokerId: item.id,
                              ),
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

  Future<void> _confirmDelete(BuildContext context, AdminRegistration item, AdminCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف طلب التسجيل'),
        content: Text('هل أنت متأكد من حذف حساب "${item.fullName}"؟ لن يتمكن من تسجيل الدخول.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.deleteRegistration(item.id);
    }
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({
    required this.registration,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.onGrantCommission,
  });

  final AdminRegistration registration;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onGrantCommission;

  @override
  Widget build(BuildContext context) {
    final reg = registration;
    final isApproved = reg.isApproved;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved ? AppColors.border : AppColors.brandDark.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.brand.withValues(alpha: 0.15),
                backgroundImage: reg.photoUrl != null
                    ? NetworkImage(
                        CloudinaryService.optimizeUrl(reg.photoUrl!, width: 100, height: 100),
                      )
                    : null,
                child: reg.photoUrl == null
                    ? Text(
                        reg.fullName.isEmpty ? '؟' : reg.fullName.characters.first,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandDark,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reg.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المحافظة: ${reg.governorate} · تاريخ الميلاد: ${Formatters.date(reg.birthDate)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved
                      ? AppColors.brand.withValues(alpha: 0.12)
                      : const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isApproved ? AppColors.brandDark.withValues(alpha: 0.25) : const Color(0xFFFECDCA),
                  ),
                ),
                child: Text(
                  isApproved ? 'حساب معتمد' : 'قيد المراجعة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isApproved ? AppColors.brandDark : const Color(0xFFB42318),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Payment Details
          Row(
            children: [
              if (reg.instaPayNumber != null && reg.instaPayNumber!.isNotEmpty)
                Expanded(
                  child: _DetailChip(
                    label: 'إنستاباي',
                    value: reg.instaPayNumber!,
                    icon: IconsaxPlusLinear.bank,
                  ),
                ),
              if (reg.walletNumber != null && reg.walletNumber!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailChip(
                    label: 'المحفظة',
                    value: reg.walletNumber!,
                    icon: IconsaxPlusLinear.wallet_1,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Communication & Actions Row
          Row(
            children: [
              Text(
                'انضم: ${Formatters.date(reg.createdAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              const Spacer(),
              // Phone call
              IconButton.filledTonal(
                onPressed: () => Launcher.call(reg.phone),
                icon: const Icon(IconsaxPlusLinear.call, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.brandDark,
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 6),
              // WhatsApp
              IconButton.filledTonal(
                onPressed: () => Launcher.whatsapp(reg.whatsapp),
                icon: const Icon(IconsaxPlusLinear.message, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.whatsapp,
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 6),
              // Delete
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(IconsaxPlusLinear.trash, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.favorite,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Status Action Buttons
          Row(
            children: [
              if (!isApproved)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(IconsaxPlusBold.verify, size: 18),
                    label: const Text('قبول واعتماد الحساب'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(IconsaxPlusLinear.close_circle, size: 18),
                    label: const Text('تعطيل الحساب'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.favorite,
                      side: const BorderSide(color: Color(0xFFFECDCA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onGrantCommission,
                    icon: const Icon(IconsaxPlusBold.money_add, size: 18),
                    label: const Text('إسناد عمولة'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
