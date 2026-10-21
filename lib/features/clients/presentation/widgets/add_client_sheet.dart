import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../domain/usecases/add_client.dart';
import '../cubit/clients_cubit.dart';

/// شيت إضافة عميل: الاسم، الرقم، اهتمامه (اقتراحات من الكمبوندات)، وملاحظة.
class AddClientSheet extends StatefulWidget {
  const AddClientSheet({this.initialInterest, super.key});

  final String? initialInterest;

  static Future<void> show(BuildContext context, {String? initialInterest}) {
    ClientsCubit cubit;
    try {
      cubit = context.read<ClientsCubit>();
    } catch (_) {
      cubit = sl<ClientsCubit>();
    }
    cubit
      ..resetAddStatus()
      ..loadCompoundNames();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddClientSheet(initialInterest: initialInterest),
      ),
    );
  }

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final TextEditingController _interestController;
  final _noteController = TextEditingController();
  final _interestFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _interestController = TextEditingController(text: widget.initialInterest ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _interestController.dispose();
    _noteController.dispose();
    _interestFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    context.read<ClientsCubit>().addClient(
      AddClientParams(
        name: _nameController.text,
        phone: _phoneController.text,
        interest: _interestController.text,
        note: _noteController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: BlocConsumer<ClientsCubit, ClientsState>(
        listenWhen: (a, b) => a.addStatus != b.addStatus,
        listener: (context, state) {
          if (state.addStatus == AddClientStatus.success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تمت إضافة العميل')));
          } else if (state.addStatus == AddClientStatus.failure &&
              state.addError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.addError!)));
          }
        },
        builder: (context, state) {
          final submitting = state.addStatus == AddClientStatus.submitting;
          final names = state.compoundNames ?? const <String>[];
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'إضافة عميل جديد',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سجّل بيانات العميل عشان تتابع معاه',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'اسم العميل',
                    controller: _nameController,
                    hint: 'اكتب اسم العميل',
                    textInputAction: TextInputAction.next,
                    prefixIcon: IconsaxPlusLinear.user,
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'اسم العميل مطلوب'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: IconsaxPlusLinear.call,
                    validator: Validators.egyptianPhone,
                  ),
                  const SizedBox(height: 12),
                  RawAutocomplete<String>(
                    textEditingController: _interestController,
                    focusNode: _interestFocus,
                    optionsBuilder: (value) {
                      final query = value.text.trim();
                      if (query.isEmpty) return names;
                      return names.where((n) => n.contains(query));
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmit) =>
                            AppFormField(
                              label: 'كان مهتم بـ',
                              controller: controller,
                              focusNode: focusNode,
                              hint: 'اسم كمبوند أو وصف الاهتمام',
                              textInputAction: TextInputAction.next,
                              prefixIcon: IconsaxPlusLinear.heart,
                              validator: (value) =>
                                  (value?.trim().isEmpty ?? true)
                                  ? 'اكتب اهتمام العميل'
                                  : null,
                            ),
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 160),
                            width: MediaQuery.widthOf(context) - 40,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    IconsaxPlusLinear.building_4,
                                    size: 18,
                                    color: AppColors.brand,
                                  ),
                                  title: Text(
                                    option,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'ملاحظة (اختياري)',
                    controller: _noteController,
                    hint: 'مثال: عايز يدفع كاش، هيرد آخر الأسبوع',
                    textInputAction: TextInputAction.done,
                    prefixIcon: IconsaxPlusLinear.note,
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    label: submitting ? 'جاري الحفظ…' : 'حفظ العميل',
                    icon: IconsaxPlusBold.add_circle,
                    loading: submitting,
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    onPressed: submitting ? () {} : _submit,
                  ),
                ],
              ),
            ),
          ));
        },
      ),
    );
  }
}
