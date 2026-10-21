import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ودجت تأثير الشيمر (الهيكل الرمادي المتدرج مثل فيسبوك وتطبيقات الميتا الحديثة)
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E7EB),
      highlightColor: const Color(0xFFF8F9FA),
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// صندوق شيمر بديل للعناصر النصية والصور والأزرار أثناء التحميل
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
