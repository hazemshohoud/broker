import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// هيدر شاشات الدخول/التسجيل: خلفية كحلي متدرجة ولوجو بروكر.
/// [compact] نسخة أصغر بزرار رجوع للشاشات اللي فيها محتوى كتير.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.title = '',
    this.subtitle,
    this.compact = false,
    this.onBackPressed,
    this.headerImage,
  });

  final String title;
  final String? subtitle;
  final bool compact;
  final VoidCallback? onBackPressed;
  final Widget? headerImage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    final titleText = title.isEmpty
        ? null
        : Text(
            title,
            style: (compact ? textTheme.titleLarge : textTheme.headlineSmall)
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          );
    final subtitleText = subtitle == null
        ? null
        : Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: compact ? -30 : -50,
              bottom: compact ? -40 : -60,
              child: Opacity(
                opacity: 0.05,
                child: BrandLogo(
                  size: compact ? 150 : 240,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                topInset + (compact ? 4 : 40),
                20,
                compact ? 22 : 44,
              ),
              child: compact
                  ? Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onBackPressed ??
                                () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  width: 1.2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  IconsaxPlusLinear.arrow_right_3,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (titleText != null) titleText,
                              if (subtitleText != null) subtitleText,
                            ],
                          ),
                        ),
                        const BrandLogo(size: 34),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: headerImage ??
                          Column(
                            children: [
                              const BrandLogo(size: 64),
                              if (titleText != null) ...[
                                const SizedBox(height: 20),
                                titleText,
                              ],
                              if (subtitleText != null) ...[
                                const SizedBox(height: 6),
                                subtitleText,
                              ],
                            ],
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
