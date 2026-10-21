import 'package:flutter/material.dart';

import '../services/cloudinary_service.dart';
import 'app_shimmer.dart';

/// صورة شبكية مدعومة بكاش Flutter المدمج مع تأثير شيمر هيكلي أثناء التحميل
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.useShimmer = true,
  });

  final String? url;
  final Widget placeholder;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool useShimmer;

  @override
  Widget build(BuildContext context) {
    final rawUrl = url;
    if (rawUrl == null || rawUrl.isEmpty) return placeholder;
    final imageUrl = CloudinaryService.optimizeUrl(rawUrl);

    return Image.network(
      imageUrl,
      fit: fit,
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      errorBuilder: (_, __, ___) => placeholder,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return useShimmer
            ? AppShimmer(
                child: ShimmerBox(
                  borderRadius: 0,
                  width: width ?? double.infinity,
                  height: height ?? double.infinity,
                ),
              )
            : placeholder;
      },
    );
  }
}
