import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/offer.dart';
import '../pages/compound_details_page.dart';

class OffersCarousel extends StatelessWidget {
  const OffersCarousel({
    super.key,
    this.projectCompounds = const [],
    this.offers = const [],
    this.scrollController,
  });

  final List<Compound> projectCompounds;
  final List<Offer> offers;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final itemCount = projectCompounds.isNotEmpty
        ? projectCompounds.length + offers.length
        : offers.length;

    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index < projectCompounds.length) {
            final compound = projectCompounds[index];
            return _ProjectCompoundCard(
              compound: compound,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompoundDetailsPage(compound: compound),
                  ),
                );
              },
            );
          }
          final offer = offers[index - projectCompounds.length];
          return _OfferCard(offer: offer);
        },
      ),
    );
  }
}

class _ProjectCompoundCard extends StatelessWidget {
  const _ProjectCompoundCard({
    required this.compound,
    required this.onTap,
  });

  final Compound compound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = compound.effectiveProjectImageUrl ?? compound.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              AppNetworkImage(
                url: imageUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: AppColors.primary,
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.apartment_rounded, color: Colors.white54, size: 36),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
          ? AppNetworkImage(
              url: offer.imageUrl,
              fit: BoxFit.cover,
              placeholder: Container(
                color: AppColors.primary,
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
    );
  }
}
