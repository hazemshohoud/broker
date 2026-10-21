import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../domain/entities/withdrawal.dart';
import '../cubit/commissions_cubit.dart';
import 'payout_labels.dart';

Future<void> showWithdrawSheet(BuildContext context) {
  final cubit = context.read<CommissionsCubit>()..resetWithdrawStatus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _WithdrawSheet()),
  );
}

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet();

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late PayoutMethod? _method = context
      .read<CommissionsCubit>()
      .state
      .wallet
      .payoutMethods
      .firstOrNull;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false) || _method == null) {
      return;
    }
    context.read<CommissionsCubit>().requestWithdrawal(
      amount: double.parse(_amountController.text),
      method: _method!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<CommissionsCubit, CommissionsState>(
      listenWhen: (a, b) => a.withdrawStatus != b.withdrawStatus,
      listener: (context, state) {
        if (state.withdrawStatus == WithdrawStatus.success) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('تم إرسال طلب السحب، هيتم التحويل بعد المراجعة'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryDark,
            ),
          );
        }
      },
      builder: (context, state) {
        final available = state.wallet.availableBalance;
        final methods = state.wallet.payoutMethods;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                Center(
                  child: Column(
                    children: [
                      Text(
                        'سحب العمولة',
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الرصيد المتاح: ${Formatters.number(available)} جنيه',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppFormField(
                  label: 'المبلغ',
                  hint: 'اكتب المبلغ بالجنيه',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: IconsaxPlusLinear.money_3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffixIcon: TextButton(
                    onPressed: () =>
                        _amountController.text = available.floor().toString(),
                    child: const Text('الكل'),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    if (amount == null || amount <= 0) return 'اكتب مبلغ صحيح';
                    if (amount > available) {
                      return 'المبلغ أكبر من رصيدك المتاح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'استلام على',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (methods.isEmpty)
                  Text(
                    'مفيش وسيلة استلام مسجلة في حسابك',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                RadioGroup<PayoutMethod>(
                  groupValue: _method,
                  onChanged: (method) => setState(() => _method = method),
                  child: Column(
                    children: [
                      for (final method in methods)
                        _MethodTile(
                          method: method,
                          selected: method == _method,
                          onTap: () => setState(() => _method = method),
                        ),
                    ],
                  ),
                ),
                if (state.withdrawStatus == WithdrawStatus.failure &&
                    state.withdrawError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.withdrawError!,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'تأكيد طلب السحب',
                  loading: state.withdrawStatus == WithdrawStatus.submitting,
                  onPressed: methods.isEmpty ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PayoutMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? AppColors.brand.withValues(alpha: 0.1)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.brand : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Radio<PayoutMethod>(
                  value: method,
                  activeColor: AppColors.brand,
                ),
                Icon(
                  method.type.icon,
                  color: selected ? AppColors.brand : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.type.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        method.number,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
