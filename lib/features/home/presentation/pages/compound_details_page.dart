import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/launcher.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/whatsapp_logo.dart';
import '../../../clients/presentation/widgets/add_client_sheet.dart';
import '../../domain/entities/compound.dart';

/// صفحة بروفايل وتفاصيل المشروع بتصميم فاخر مع ربط كامل بقاعدة البيانات
class CompoundDetailsPage extends StatefulWidget {
  const CompoundDetailsPage({super.key, required this.compound});

  final Compound compound;

  @override
  State<CompoundDetailsPage> createState() => _CompoundDetailsPageState();
}

class _CompoundDetailsPageState extends State<CompoundDetailsPage> {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _shareCompound() {
    final c = widget.compound;
    final text = 'تفاصيل مشروع ${c.name} - ${c.developerName}\n'
        'الموقع: ${c.location}\n'
        'المساحة: ${c.effectiveArea}\n'
        'تاريخ الاستلام: ${c.effectiveDeliveryDate}\n'
        'بداية السعر: ${Formatters.price(c.developerStartPrice)}\n'
        'العمولة: ${Formatters.price(c.commission)}\n'
        'تطبيق بروكر العقاري';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ تفاصيل العقار إلى الحافظة بنجاح'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openRequestViewingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RequestViewingSheet(compound: widget.compound),
    );
  }

  void _openAddPotentialClientSheet() {
    AddClientSheet.show(
      context,
      initialInterest: widget.compound.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compound = widget.compound;
    final phone = compound.phone;
    final whatsapp = compound.whatsapp ?? compound.phone;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          cacheExtent: 1400,
          slivers: [
            // 1. Hero Gallery with In-Image Controls & Info (صور داخلها العنوان - الشير - لوجو المطور)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _HeroGalleryHeader(
                  compound: compound,
                  pageController: _imagePageController,
                  currentIndex: _currentImageIndex,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  onShare: _shareCompound,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Content List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  // 2. عنوان العقار التفصيلي
                  _LocationAddressCard(compound: compound),
                  const SizedBox(height: 14),

                  // 3. حالة العقار (جاهز / قيد الإنشاء) وموعد الاستلام والمساحة
                  _QuickSpecsGrid(compound: compound),
                  const SizedBox(height: 14),

                  // 4. السعر والعمولة
                  _PricingAndCommissionCard(compound: compound),
                  const SizedBox(height: 14),

                  // 5. أنواع الوحدات والتشطيب
                  _UnitsAndFinishingCard(compound: compound),
                  const SizedBox(height: 14),

                  // 6. خريطة العقار (Property Map)
                  _PropertyMapCard(compound: compound),
                  const SizedBox(height: 14),

                  // 7. الخدمات القريبة والمسافات (المرفقات)
                  if (compound.effectiveAmenities.isNotEmpty) ...[
                    _AmenitiesCard(amenities: compound.effectiveAmenities),
                    const SizedBox(height: 14),
                  ],

                  // 8. الأسئلة الشائعة (Accordion V)
                  _FaqAccordionCard(faqs: compound.effectiveFaqs),
                  const SizedBox(height: 14),
                ]),
              ),
            ),
          ],
        ),

        // الأزرار السفلية (عميل محتمل + حجز معاينة + اتصل بالشركة + واتساب)
        bottomNavigationBar: _BottomActionBar(
          phone: phone,
          whatsapp: whatsapp,
          onAddClient: _openAddPotentialClientSheet,
          onRequestViewing: _openRequestViewingSheet,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Hero Gallery Header (الصور، العنوان، الشير، لوجو المطور)
// -----------------------------------------------------------------------------
class _HeroGalleryHeader extends StatelessWidget {
  const _HeroGalleryHeader({
    required this.compound,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onShare,
    required this.onBack,
  });

  final Compound compound;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onShare;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final images = compound.allImages;
    final topPadding = MediaQuery.of(context).padding.top;

    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Images PageView
          if (images.isNotEmpty)
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: AppNetworkImage(
                    url: images[index],
                    fit: BoxFit.cover,
                    placeholder: ColoredBox(
                      color: AppColors.primaryDark,
                      child: Center(
                        child: Text(
                          compound.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              color: AppColors.primaryDark,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apartment_rounded, size: 54, color: Colors.white54),
                    const SizedBox(height: 8),
                    Text(
                      compound.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top gradient for controls visibility (wrapped in IgnorePointer to unblock swiping)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom gradient for title and developer overlay (wrapped in IgnorePointer to unblock swiping)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 170,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.92),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top Action Buttons Row (الرجوع - لوجو المطور - الشير)
          Positioned(
            top: topPadding + 8,
            left: 14,
            right: 14,
            child: Row(
              children: [
                // Back Button
                _FrostedGlassButton(
                  icon: IconsaxPlusLinear.arrow_right_3,
                  onTap: onBack,
                  tooltip: 'رجوع',
                ),
                const Spacer(),

                // Share Button
                _FrostedGlassButton(
                  icon: IconsaxPlusLinear.share,
                  onTap: onShare,
                  tooltip: 'مشاركة',
                ),
              ],
            ),
          ),


          // Bottom Title & Info inside Image
          Positioned(
            bottom: 14,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  compound.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Developer Logo opposite Developer Name + Location + Counter
                Row(
                  children: [
                    // Developer Logo right opposite Developer Name
                    if (compound.developerLogoUrl != null &&
                        compound.developerLogoUrl!.isNotEmpty) ...[
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AppNetworkImage(
                          url: compound.developerLogoUrl,
                          fit: BoxFit.cover,
                          placeholder: Center(
                            child: Text(
                              compound.developerName.isNotEmpty
                                  ? compound.developerName.characters.first
                                  : 'م',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      compound.developerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        compound.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Counter Pill (قابلة للضغط للتبديل السريع بين الصور)
                    if (images.length > 1)
                      GestureDetector(
                        onTap: () {
                          final next = (currentIndex + 1) % images.length;
                          pageController.animateToPage(
                            next,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
  }
}

class _FrostedGlassButton extends StatelessWidget {
  const _FrostedGlassButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. بطاقة المطور وعنوان وموقع العقار
// -----------------------------------------------------------------------------
class _LocationAddressCard extends StatelessWidget {
  const _LocationAddressCard({required this.compound});

  final Compound compound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // لوجو الشركة قصاد اسم المطور
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (compound.developerLogoUrl != null &&
                      compound.developerLogoUrl!.isNotEmpty) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppNetworkImage(
                        url: compound.developerLogoUrl,
                        fit: BoxFit.cover,
                        placeholder: Center(
                          child: Text(
                            compound.developerName.isNotEmpty
                                ? compound.developerName.characters.first
                                : 'م',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المطور العقاري',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        compound.developerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'مطور معتمد',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),

          // تفاصيل عنوان العقار
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عنوان العقار والموقع',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                compound.location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              if (compound.region != null || compound.district != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (compound.region != null)
                      _TagPill(label: compound.region!),
                    if (compound.district != null)
                      _TagPill(label: compound.district!),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. حالة العقار (جاهز / قيد الإنشاء) وتاريخ الاستلام والمساحة
// -----------------------------------------------------------------------------
class _QuickSpecsGrid extends StatelessWidget {
  const _QuickSpecsGrid({required this.compound});

  final Compound compound;

  @override
  Widget build(BuildContext context) {
    final isReady = (compound.readiness == 'جاهز');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المواصفات الأساسية',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // حالة العقار (جاهز - قيد الإنشاء)
              Expanded(
                child: _SpecCardItem(
                  title: 'حالة العقار',
                  value: compound.readiness ?? (isReady ? 'جاهز' : 'قيد الإنشاء'),
                  badgeColor: isReady ? AppColors.brandDark : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),

              // تاريخ الاستلام
              Expanded(
                child: _SpecCardItem(
                  title: 'تاريخ الاستلام',
                  value: compound.effectiveDeliveryDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // المساحة
              Expanded(
                child: _SpecCardItem(
                  title: 'المساحة',
                  value: compound.effectiveArea,
                ),
              ),
              const SizedBox(width: 10),

              // التشطيب
              Expanded(
                child: _SpecCardItem(
                  title: 'التشطيب',
                  value: compound.finishing ?? 'تشطيب كامل',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecCardItem extends StatelessWidget {
  const _SpecCardItem({
    required this.title,
    required this.value,
    this.badgeColor,
  });

  final String title;
  final String value;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: badgeColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. السعر والعمولة
// -----------------------------------------------------------------------------
class _PricingAndCommissionCard extends StatelessWidget {
  const _PricingAndCommissionCard({required this.compound});

  final Compound compound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'السعر والعمولة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Pricing Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'بداية سعر المطور',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.price(compound.developerStartPrice),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.borderLight),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سعر إعادة البيع',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      compound.resaleStartPrice == null
                          ? 'غير متوفر'
                          : Formatters.price(compound.resaleStartPrice!),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: compound.resaleStartPrice != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Commission Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عمولتك كوسيط على هذا المشروع',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.price(compound.commission),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brand),
                  ),
                  child: const Text(
                    'مضمونة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand,
                    ),
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

// -----------------------------------------------------------------------------
// 5. أنواع الوحدات والتشطيب
// -----------------------------------------------------------------------------
class _UnitsAndFinishingCard extends StatelessWidget {
  const _UnitsAndFinishingCard({required this.compound});

  final Compound compound;

  @override
  Widget build(BuildContext context) {
    if (compound.propertyTypes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أنواع الوحدات المتاحة بالمشروع',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: compound.propertyTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. خريطة العقار (Property Map)
// -----------------------------------------------------------------------------
class _PropertyMapCard extends StatelessWidget {
  const _PropertyMapCard({required this.compound});

  final Compound compound;

  @override
  Widget build(BuildContext context) {
    final mapUrl = compound.mapUrl ??
        'https://maps.google.com/?q=${Uri.encodeComponent('${compound.name} ${compound.location}')}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'خريطة وموقع العقار',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    compound.district ?? compound.location,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Stylized Map Graphic Preview
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                height: 150,
                width: double.infinity,
                child: AppNetworkImage(
                  url: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  placeholder: ColoredBox(color: Color(0xFFE2E8F0)),
                ),
              ),
              Container(
                height: 150,
                color: Colors.black.withValues(alpha: 0.25),
              ),

              // Pin in Center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      compound.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 34,
                    color: Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),

          // Open in Google Maps Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Launcher.url(mapUrl),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                child: const Text('فتح الموقع في خرائط Google'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 8. الخدمات القريبة والمسافات (10 خدمات مع المسافات من الصورة)
// -----------------------------------------------------------------------------
class _AmenitiesCard extends StatelessWidget {
  const _AmenitiesCard({required this.amenities});

  final Map<String, String> amenities;

  @override
  Widget build(BuildContext context) {
    final validAmenities = amenities.entries
        .where((e) => e.key.trim().isNotEmpty)
        .toList();

    if (validAmenities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الخدمات القريبة من العقار',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'المسافة التقديرية لأهم المرافق الحيوية المجاورة',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid of Amenities
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: validAmenities.map((entry) {
                  return Container(
                    width: itemWidth > 120 ? itemWidth : constraints.maxWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.value.isNotEmpty ? entry.value : '1 كم',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 9. الأسئلة الشائعة (Accordion V)
// -----------------------------------------------------------------------------
class _FaqAccordionCard extends StatelessWidget {
  const _FaqAccordionCard({required this.faqs});

  final Map<String, String> faqs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الأسئلة الشائعة حول المشروع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'إجابات شاملة لمساعدتك في إقناع عملائك',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accordion items
          ...faqs.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    iconColor: AppColors.brandDark,
                    collapsedIconColor: AppColors.textSecondary,
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    children: [
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// 11. الأزرار السفلية (+ عميل محتمل + حجز معاينة + اتصل بالشركة + واتساب)
// -----------------------------------------------------------------------------
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.phone,
    required this.whatsapp,
    required this.onAddClient,
    required this.onRequestViewing,
  });

  final String? phone;
  final String? whatsapp;
  final VoidCallback onAddClient;
  final VoidCallback onRequestViewing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
      child: SafeArea(
        child: Row(
          children: [
            // زر: + عميل محتمل (أسود صريح مع كلام أبيض)
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: onAddClient,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  '+ عميل محتمل',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // زر: + حجز معاينة (أسود مع كلام أبيض)
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: onRequestViewing,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  '+ حجز معاينة',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // أيقونة الواتساب — نفس المستخدمة في صفحة الهوم في كارت العقار
            Tooltip(
              message: 'واتساب',
              child: InkResponse(
                onTap: whatsapp == null ? null : () => Launcher.whatsapp(whatsapp!),
                radius: 22,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: WhatsAppLogo(size: 26),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // أيقونة الاتصال — نفس المستخدمة في صفحة الهوم في كارت العقار
            Tooltip(
              message: 'اتصال',
              child: InkResponse(
                onTap: phone == null ? null : () => Launcher.call(phone!),
                radius: 22,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.phone_rounded,
                    size: 26,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}

// -----------------------------------------------------------------------------
// شيت حجز معاينة
// -----------------------------------------------------------------------------
class _RequestViewingSheet extends StatefulWidget {
  const _RequestViewingSheet({required this.compound});

  final Compound compound;

  @override
  State<_RequestViewingSheet> createState() => _RequestViewingSheetState();
}

class _RequestViewingSheetState extends State<_RequestViewingSheet> {
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final clientName = _clientNameController.text.trim();
    final clientPhone = _clientPhoneController.text.trim();
    final notes = _notesController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final brokerName = CurrentUserHolder.cachedUserName ?? 'وسيط';

      await FirebaseFirestore.instance.collection('viewing_requests').add({
        'brokerId': user?.uid,
        'brokerName': brokerName,
        'brokerEmail': user?.email,
        'compoundId': widget.compound.id,
        'compoundName': widget.compound.name,
        'developerName': widget.compound.developerName,
        'location': widget.compound.location,
        'clientName': clientName.isNotEmpty ? clientName : brokerName,
        'clientPhone': clientPhone,
        'viewingDate': Timestamp.fromDate(_selectedDate),
        'notes': notes,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(IconsaxPlusBold.tick_circle, color: AppColors.brand, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تم إرسال طلب المعاينة إلى الإدارة بنجاح، وسيتم التواصل معك لتأكيد الموعد.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إرسال الطلب: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'طلب حجز موعد معاينة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل (اختياري)',
                  hintText: 'اسم العميل المهتم بالمعاينة',
                  prefixIcon: Icon(IconsaxPlusLinear.user),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clientPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف العميل (اختياري)',
                  hintText: '01xxxxxxxxx',
                  prefixIcon: Icon(IconsaxPlusLinear.call),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                title: const Text('تاريخ المعاينة', style: TextStyle(fontSize: 13)),
                subtitle: Text(
                  Formatters.date(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandDark),
                ),
                trailing: const Icon(IconsaxPlusLinear.calendar, color: AppColors.brandDark),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات المعاينة (اختياري)',
                  hintText: 'الوقت المفضل أو تفاصيل الوحدة المطلوبة...',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black45,
                  disabledForegroundColor: Colors.white70,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تأكيد وإرسال طلب المعاينة للإدارة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
