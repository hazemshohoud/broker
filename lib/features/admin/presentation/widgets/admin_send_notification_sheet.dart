import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../domain/entities/admin_registration.dart';
import '../cubit/admin_cubit.dart';

/// شيت إرسال إشعار فوري من الإدارة للوسطاء (عام أو مخصص)
class AdminSendNotificationSheet extends StatefulWidget {
  const AdminSendNotificationSheet({
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
      builder: (_) => AdminSendNotificationSheet(
        cubit: cubit,
        registrations: registrations,
        preselectedBrokerId: preselectedBrokerId,
      ),
    );
  }

  @override
  State<AdminSendNotificationSheet> createState() => _AdminSendNotificationSheetState();
}

class _AdminSendNotificationSheetState extends State<AdminSendNotificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  late String? _selectedBrokerId = widget.preselectedBrokerId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final success = await widget.cubit.sendNotification(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      brokerId: _selectedBrokerId,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final approvedBrokers = widget.registrations.where((r) => r.isApproved).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.brand.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      IconsaxPlusBold.notification_bing,
                      color: AppColors.brandDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرسال إشعار فوري',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'يصل مباشرة لأيقونة الإشعارات في التطبيق',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // المستلم
              const Text(
                'المستلم',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedBrokerId,
                    isExpanded: true,
                    icon: const Icon(IconsaxPlusLinear.arrow_down_1, size: 18),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          '📢 جميع الوسطاء (إشعار عام)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandDark,
                          ),
                        ),
                      ),
                      ...approvedBrokers.map(
                        (b) => DropdownMenuItem<String?>(
                          value: b.id,
                          child: Text(
                            '👤 ${b.fullName} (${b.phone})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedBrokerId = val),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // العنوان
              AppFormField(
                controller: _titleController,
                label: 'عنوان الإشعار',
                hint: 'مثال: تحديث هام في الأسعار أو عمولة جديدة',
                prefixIcon: IconsaxPlusLinear.edit,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة عنوان الإشعار';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // النص
              AppFormField(
                controller: _bodyController,
                label: 'نص الإشعار',
                hint: 'تفاصيل التنبيه أو الرسالة الموجهة للوسطاء...',
                prefixIcon: IconsaxPlusLinear.message_text,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة نص الإشعار';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // قوالب سريعة
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickChip(
                    label: 'مشروع جديد متاح',
                    onTap: () {
                      _titleController.text = 'مشروع جديد متاح للحجز 🏢';
                      _bodyController.text = 'تمت إضافة كمبوند جديد بعمولات مميزة، تصفحه الآن وقدم عملاءك.';
                    },
                  ),
                  _QuickChip(
                    label: 'تحديث في العمولات',
                    onTap: () {
                      _titleController.text = 'تحديث نسب العمولات 💰';
                      _bodyController.text = 'تم تحديث نسب العمولات الخاصة ببعض المشروعات، راجع التفاصيل في التطبيق.';
                    },
                  ),
                  _QuickChip(
                    label: 'تنبيه إداري',
                    onTap: () {
                      _titleController.text = 'تنبيه من إدارة منصة بروكر 📢';
                      _bodyController.text = 'نحيطكم علماً ببدء استقبال طلبات المعاينات المباشرة لجميع المشروعات.';
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconsaxPlusBold.send_1, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'إرسال الإشعار الآن',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
