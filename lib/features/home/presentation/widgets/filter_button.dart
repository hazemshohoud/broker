import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// زرار الفلتر جنب عنوان "كمبوندات في مصر" — بيعرض عدد الفلاتر المفعّلة.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    return Badge(
      isLabelVisible: active,
      label: Text(
        '$activeCount',
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
      ),
      backgroundColor: AppColors.brand,
      textColor: AppColors.primaryDark,
      child: IconButton(
        onPressed: onTap,
        splashRadius: 22,
        tooltip: 'تصفية الكمبوندات',
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        icon: Image.asset(
          'assets/icons/filter_sliders.png',
          width: 24,
          height: 24,
          color: active ? AppColors.brand : AppColors.textPrimary,
        ),
      ),
    );
  }
}
