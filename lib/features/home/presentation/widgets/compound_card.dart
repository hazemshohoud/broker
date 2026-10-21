import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/whatsapp_logo.dart';
import '../../domain/entities/compound.dart';

class CompoundCard extends StatelessWidget {
  const CompoundCard({
    super.key,
    required this.compound,
    this.onTap,
    this.onCallTap,
    this.onWhatsAppTap,
  });

  final Compound compound;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(compound: compound),
            _Details(
              compound: compound,
              onCallTap: onCallTap,
              onWhatsAppTap: onWhatsAppTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  const _Hero({required this.compound});

  final Compound compound;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenGalleryPage(
          images: images,
          initialIndex: initialIndex,
          title: widget.compound.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final images = widget.compound.allImages;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.86,
        child: ColoredBox(
          color: AppColors.cardHero,
          child: Center(
            child: Text(
              widget.compound.developerName.toUpperCase(),
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    if (images.length == 1) {
      return AspectRatio(
        aspectRatio: 1.86,
        child: GestureDetector(
          onTap: () => _openGallery(context, images, 0),
          child: AppNetworkImage(
            url: images.first,
            placeholder: ColoredBox(
              color: AppColors.cardHero,
              child: Center(
                child: Text(
                  widget.compound.developerName.toUpperCase(),
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.86,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openGallery(context, images, index),
                child: AppNetworkImage(
                  url: images[index],
                  fit: BoxFit.cover,
                  placeholder: ColoredBox(
                    color: AppColors.cardHero,
                    child: Center(
                      child: Text(
                        widget.compound.developerName.toUpperCase(),
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Page Indicator Pill
          Positioned(
            bottom: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentPage + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Dots Indicator
          Positioned(
            bottom: 12,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(images.length, (dotIndex) {
                final isActive = dotIndex == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.brand : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenGalleryPage extends StatefulWidget {
  const _FullScreenGalleryPage({
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  final List<String> images;
  final int initialIndex;
  final String title;

  @override
  State<_FullScreenGalleryPage> createState() => _FullScreenGalleryPageState();
}

class _FullScreenGalleryPageState extends State<_FullScreenGalleryPage> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '${_currentIndex + 1} من ${widget.images.length}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 3.5,
            child: Center(
              child: AppNetworkImage(
                url: widget.images[index],
                fit: BoxFit.contain,
                placeholder: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.compound,
    this.onCallTap,
    this.onWhatsAppTap,
  });

  final Compound compound;
  final VoidCallback? onCallTap;
  final VoidCallback? onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compound.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            compound.developerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.brandDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        if (compound.location.isNotEmpty) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              compound.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: (compound.developerLogoUrl != null &&
                        compound.developerLogoUrl!.isNotEmpty)
                    ? AppNetworkImage(
                        url: compound.developerLogoUrl,
                        fit: BoxFit.cover,
                        placeholder: Center(
                          child: Text(
                            compound.developerName.isNotEmpty
                                ? compound.developerName.characters.first
                                : 'م',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.brandDark,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          compound.developerName.isNotEmpty
                              ? compound.developerName.characters.first
                              : 'م',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.brandDark,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (compound.propertyTypes.isNotEmpty) ...[
            const SizedBox(height: 10),
            _PropertyTypes(types: compound.propertyTypes),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _Price(
                label: 'بداية سعر المطور',
                value: Formatters.price(compound.developerStartPrice),
              ),
              _Price(
                label: 'بداية سعر إعادة البيع',
                value: compound.resaleStartPrice == null
                    ? 'غير متوفر'
                    : Formatters.price(compound.resaleStartPrice!),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: _Commission(amount: compound.commission),
                ),
                const SizedBox(width: 16),
                // أيقونة الواتساب مباشرة بعد العمولة — بدون أي مربع أو دوائر أو ظلال
                _BareIconButton(
                  tooltip: 'واتساب',
                  onTap: onWhatsAppTap,
                  child: const WhatsAppLogo(size: 25),
                ),
                const SizedBox(width: 14),
                // أيقونة الاتصال بعد الواتساب — بدون أي مربع أو دوائر أو ظلال
                _BareIconButton(
                  tooltip: 'اتصال',
                  onTap: onCallTap,
                  child: const Icon(
                    Icons.phone_rounded,
                    size: 25,
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BareIconButton extends StatelessWidget {
  const _BareIconButton({
    required this.tooltip,
    required this.child,
    this.onTap,
  });

  final String tooltip;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}

class _PropertyTypes extends StatelessWidget {
  const _PropertyTypes({required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return SizedBox(
      height: 22,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, _) =>
            const VerticalDivider(width: 17, indent: 2, endIndent: 2),
        itemBuilder: (_, index) =>
            Center(child: Text(types[index], style: style)),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Commission extends StatelessWidget {
  const _Commission({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'العمولة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.price(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

