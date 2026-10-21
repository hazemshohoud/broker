import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'terms_text.dart';

class TermsStep extends StatefulWidget {
  const TermsStep({
    super.key,
    required this.accepted,
    required this.onAcceptedChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onAcceptedChanged;

  @override
  State<TermsStep> createState() => _TermsStepState();
}

class _TermsStepState extends State<TermsStep> {
  /// Own controller: without it the Scrollbar falls back to the
  /// PrimaryScrollController shared with the other steps' lists and asserts.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  termsText,
                  style: textTheme.bodySmall?.copyWith(height: 1.8),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: CheckboxListTile(
            value: widget.accepted,
            onChanged: (value) => widget.onAcceptedChanged(value ?? false),
            title: Text(
              'أوافق على الشروط والأحكام',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'برجاء قراءة الشروط والأحكام بعناية.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.brand,
            checkColor: Colors.white,
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
}
