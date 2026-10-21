import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/offer.dart';
import 'compound_details_page.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({
    super.key,
    required this.offers,
    this.compounds = const [],
  });

  final List<Offer> offers;
  final List<Compound> compounds;

  Compound? _findMatchingCompound(String title) {
    if (compounds.isEmpty) return null;
    final clean = title.trim().toLowerCase();
    for (final c in compounds) {
      final name = c.name.toLowerCase();
      final dev = c.developerName.toLowerCase();
      if (clean.contains(name) || name.contains(clean) || (dev.isNotEmpty && clean.contains(dev))) {
        return c;
      }
    }
    return null;
  }

  void _showImageDialog(BuildContext context, Offer offer) {
    if (offer.imageUrl == null || offer.imageUrl!.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: AppNetworkImage(
                  url: offer.imageUrl!,
                  placeholder: const Center(
                    child: CircularProgressIndicator(color: AppColors.brand),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              offer.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareOffer(BuildContext context, Offer offer) {
    Clipboard.setData(
      ClipboardData(
        text: '🔥 عرض مميز من تطبيق بروكر:\n'
            '${offer.title}\n'
            'للحجز والاستفسار عن تفاصيل الوحدات والأسعار تواصل معنا.',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(IconsaxPlusBold.tick_circle, color: AppColors.brand, size: 20),
            SizedBox(width: 8),
            Text('تم نسخ تفاصيل العرض إلى الحافظة للمشاركة'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopHeader(
          showBack: true,
          title: 'المشروعات والعروض',
          subtitle: '${offers.length} عروض حصرية ومميزة',
          icon: IconsaxPlusBold.discount_shape,
        ),
        body: offers.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          IconsaxPlusBold.discount_shape,
                          size: 48,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد عروض ترويجية حالياً',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'سيتم إشعارك فور إطلاق مشاريع جديدة أو عروض وخصومات حصرية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  final matchedCompound = _findMatchingCompound(offer.title);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner image
                        if (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showImageDialog(context, offer),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 8,
                                  child: AppNetworkImage(
                                    url: offer.imageUrl!,
                                    placeholder: DecoratedBox(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.primaryDark, AppColors.primary],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            offer.title,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(IconsaxPlusBold.star_1, size: 12, color: AppColors.brand),
                                        SizedBox(width: 4),
                                        Text(
                                          'عرض مميز',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Title & Actions
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  if (matchedCompound != null)
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => CompoundDetailsPage(
                                                compound: matchedCompound,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(IconsaxPlusBold.building_4, size: 16),
                                        label: const Text('تفاصيل المشروع'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.brand,
                                          foregroundColor: AppColors.primaryDark,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showImageDialog(context, offer),
                                        icon: const Icon(IconsaxPlusLinear.eye, size: 16),
                                        label: const Text('تكبير العرض'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.textPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 10),

                                  // Share button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        IconsaxPlusLinear.share,
                                        size: 20,
                                        color: AppColors.textPrimary,
                                      ),
                                      tooltip: 'مشاركة العرض',
                                      onPressed: () => _shareOffer(context, offer),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
