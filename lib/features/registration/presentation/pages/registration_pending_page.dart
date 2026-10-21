import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../auth/presentation/pages/login_page.dart';

class RegistrationPendingPage extends StatelessWidget {
  const RegistrationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              FadeSlideIn(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDark,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.25),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const BrandLogo(size: 48),
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                duration: const Duration(milliseconds: 700),
                child: Column(
                  children: [
                    Text(
                      'جاري مراجعة بياناتك',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'هيتم تفعيل حسابك بعد موافقة الإدارة، '
                              'وتقدر تسجّل دخول بعدها برقم هاتفك.',
                              style: textTheme.bodySmall?.copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'العودة لتسجيل الدخول',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
