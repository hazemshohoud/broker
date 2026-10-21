import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// الزرار الأساسي الموحد في التطبيق، مع حالة تحميل.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.brand;
    final fg = foregroundColor ?? AppColors.primaryDark;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        foregroundColor: fg,
        disabledForegroundColor: fg.withValues(alpha: 0.5),
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: fg,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ],
            ),
    );
  }
}
