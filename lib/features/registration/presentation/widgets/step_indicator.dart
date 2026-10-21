import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.currentStep});

  final int currentStep;

  static const _titles = [
    'البيانات الأساسية',
    'طرق استلام العمولات',
    'الشروط والأحكام',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _titles.length; i++) ...[
          _StepDot(index: i, title: _titles[i], current: currentStep),
          if (i < _titles.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                color: i < currentStep
                    ? AppColors.primary
                    : AppColors.borderLight,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.title,
    required this.current,
  });

  final int index;
  final String title;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active
                ? AppColors.primary
                : AppColors.chipBackground,
            border: Border.all(
              color: done || active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
