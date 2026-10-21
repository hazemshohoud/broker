import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../registration/presentation/widgets/terms_text.dart';

/// صفحة عرض الشروط والأحكام من حسابي — نفس نص التسجيل.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الشروط والأحكام')),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              termsText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.8,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
