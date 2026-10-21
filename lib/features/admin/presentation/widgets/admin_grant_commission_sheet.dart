import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../domain/entities/admin_registration.dart';
import '../cubit/admin_cubit.dart';

class AdminGrantCommissionSheet extends StatefulWidget {
  const AdminGrantCommissionSheet({
    required this.cubit,
    required this.registrations,
    this.preselectedBrokerId,
    super.key,
  });

  final AdminCubit cubit;
  final List<AdminRegistration> registrations;
  final String? preselectedBrokerId;

  static Future<void> show(
    BuildContext context, {
    required AdminCubit cubit,
    required List<AdminRegistration> registrations,
    String? preselectedBrokerId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AdminGrantCommissionSheet(
        cubit: cubit,
        registrations: registrations,
        preselectedBrokerId: preselectedBrokerId,
      ),
    );
  }

  @override
  State<AdminGrantCommissionSheet> createState() => _AdminGrantCommissionSheetState();
}

class _AdminGrantCommissionSheetState extends State<AdminGrantCommissionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  late String? _selectedBrokerId = widget.preselectedBrokerId ??
      widget.registrations.where((r) => r.isApproved).firstOrNull?.id;
  String _status = 'approved';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _selectedBrokerId == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final success = await widget.cubit.grantCommission(
      brokerId: _selectedBrokerId!,
      amount: amount,
      title: _titleController.text.trim(),
      status: _status,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvedBrokers = widget.registrations.where((r) => r.isApproved).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إسناد عمولة لوسيط عقاري',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'سيتم تسجيل العمولة في محفظة الوسيط فوراً',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Select Broker
              const Text(
                'الوسيط المستحق',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBrokerId,
                    isExpanded: true,
                    hint: const Text('اختر الوسيط من القائمة'),
                    items: approvedBrokers.map((b) {
                      return DropdownMenuItem(
                        value: b.id,
                        child: Text('${b.fullName} (${b.phone})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBrokerId = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title / Deal description
              AppFormField(
                label: 'تفاصيل الصفقة / اسم الكمبوند',
                hint: 'مثال: وان هايد بارك - فيلا B4',
                controller: _titleController,
                prefixIcon: IconsaxPlusLinear.building_4,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'اكتب تفاصيل الصفقة' : null,
              ),
              const SizedBox(height: 16),

              // Amount
              AppFormField(
                label: 'مبلغ العمولة (ج.م)',
                hint: 'مثال: 150000',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: IconsaxPlusLinear.money_3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  final n = double.tryParse(val ?? '');
                  if (n == null || n <= 0) return 'اكتب مبلغ صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status selector
              const Text(
                'حالة العمولة',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('معتمدة وجاهزة للسحب')),
                      selected: _status == 'approved',
                      selectedColor: AppColors.brand.withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => _status = 'approved'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('قيد الاعتماد')),
                      selected: _status == 'pending',
                      selectedColor: AppColors.border,
                      onSelected: (_) => setState(() => _status = 'pending'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                      )
                    : const Text('إسناد العمولة الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
