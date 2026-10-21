import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// هيكل تحميل الصفحة الرئيسية بتأثير شيمر احترافي ناعم مطابق للتصميم الحقيقي
class HomeShimmerSkeleton extends StatelessWidget {
  const HomeShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. شريط المطورين الدائري
        SizedBox(
          height: 70,
          child: AppShimmer(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 62,
                height: 62,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. هيدر قسم المشروعات والعروض
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppShimmer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 170, height: 18, borderRadius: 6),
                ShimmerBox(width: 55, height: 16, borderRadius: 6),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. سلايدر كروت العروض المطابق للمقاس الفعلي (108 ارتفاع × 190 عرض)
        SizedBox(
          height: 108,
          child: AppShimmer(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 190,
                height: 108,
                borderRadius: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),

        // 4. هيدر قسم الكمبوندات
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppShimmer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 130, height: 18, borderRadius: 6),
                ShimmerBox(width: 36, height: 36, borderRadius: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 5. كروت العقارات بهيكل أبيض سليم وشيمر داخلي للعناصر فقط
        ...List.generate(
          2,
          (_) => const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _CompoundCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _CompoundCardSkeleton extends StatelessWidget {
  const _CompoundCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة العقار
            const AspectRatio(
              aspectRatio: 1.86,
              child: ShimmerBox(borderRadius: 0),
            ),

            // تفاصيل العقار
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ShimmerBox(width: 150, height: 18, borderRadius: 6),
                            SizedBox(height: 6),
                            ShimmerBox(width: 100, height: 13, borderRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const ShimmerBox(
                        width: 42,
                        height: 42,
                        shape: BoxShape.circle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // أنواع العقارات
                  Row(
                    children: const [
                      ShimmerBox(width: 60, height: 22, borderRadius: 6),
                      SizedBox(width: 8),
                      ShimmerBox(width: 70, height: 22, borderRadius: 6),
                      SizedBox(width: 8),
                      ShimmerBox(width: 65, height: 22, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // الأسعار
                  Row(
                    children: const [
                      Expanded(
                        child: ShimmerBox(height: 38, borderRadius: 8),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ShimmerBox(height: 38, borderRadius: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // أزرار الأكشن (عمولة + اتصال + واتساب)
                  Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: ShimmerBox(height: 48, borderRadius: 10),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ShimmerBox(height: 48, borderRadius: 10),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ShimmerBox(height: 48, borderRadius: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
