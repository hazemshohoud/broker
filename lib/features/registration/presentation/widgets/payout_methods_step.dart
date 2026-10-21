import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';

class PayoutMethodsStep extends StatelessWidget {
  const PayoutMethodsStep({
    super.key,
    required this.formKey,
    required this.instaPayController,
    required this.walletController,
    this.showMissingMethodError = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController instaPayController;
  final TextEditingController walletController;

  /// True when the user pressed next with both fields empty.
  final bool showMissingMethodError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              'طرق استلام العمولات',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'يمكنك إضافة رقم إنستاباي فقط، أو رقم محفظة إلكترونية فقط، أو كليهما معاً (يكفي وسيلة واحدة على الأقل).',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // InstaPay Field
          AppFormField(
            label: 'رقم أو عنوان الإنستاباي (InstaPay)',
            hint: 'مثال: username@instapay أو رقم الهاتف',
            controller: instaPayController,
            keyboardType: TextInputType.text,
            prefixIcon: IconsaxPlusLinear.card_send,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Wallet Field
          AppFormField(
            label: 'رقم المحفظة الإلكترونية (فودافون كاش / وي / أورنج / اتصالات)',
            hint: '01xxxxxxxxx',
            controller: walletController,
            keyboardType: TextInputType.phone,
            prefixIcon: IconsaxPlusLinear.wallet_2,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                if (!RegExp(r'^01\d{9}$').hasMatch(val.trim())) {
                  return 'رقم المحفظة يجب أن يتكون من 11 رقماً ويبدأ بـ 01';
                }
              }
              return null;
            },
          ),

          // Live Selection Status Indicator
          ListenableBuilder(
            listenable: Listenable.merge([instaPayController, walletController]),
            builder: (context, _) {
              final hasInsta = instaPayController.text.trim().isNotEmpty;
              final hasWallet = walletController.text.trim().isNotEmpty;

              if (hasInsta || hasWallet) {
                String label;
                if (hasInsta && hasWallet) {
                  label = 'تم تحديد وسيلتي الاستلام بنجاح (إنستاباي + محفظة)';
                } else if (hasInsta) {
                  label = 'تم تحديد وسيلة الاستلام: إنستاباي';
                } else {
                  label = 'تم تحديد وسيلة الاستلام: محفظة إلكترونية';
                }

                return Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brand.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(IconsaxPlusBold.tick_circle, size: 18, color: AppColors.brandDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Missing Method Error Banner
          if (showMissingMethodError)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(IconsaxPlusBold.info_circle, size: 18, color: Color(0xFFEF4444)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى كتابة وسيلة واحدة على الأقل (رقم إنستاباي أو رقم محفظة إلكترونية) لتحويل عمولاتك عليها.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Explanatory Note Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  IconsaxPlusLinear.info_circle,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'برجاء التأكد من صحة الرقم المكتوب، حيث سيتم تحويل عمولات الصفقات المكتملة عليه مباشرة ويمكنك تعديله لاحقاً من حسابك.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
