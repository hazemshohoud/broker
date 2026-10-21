import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../home/domain/entities/offer.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminOffersPage extends StatelessWidget {
  const AdminOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_right_3, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'العروض والبانرات الترويجية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOfferDialog(context),
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.primaryDark,
        icon: const Icon(IconsaxPlusBold.add_circle),
        label: const Text('إضافة عرض جديد', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final offers = state.offers;

          return RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () => cubit.loadOffers(),
            child: offers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'لا توجد عروض حالياً، اضغط على إضافة عرض بالأسفل',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: offers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (offer.imageUrl != null)
                              Image.network(
                                offer.imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                height: 80,
                                width: double.infinity,
                                color: AppColors.background,
                                child: const Icon(IconsaxPlusLinear.discount_shape, size: 36, color: AppColors.brandDark),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      offer.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    onPressed: () => _showOfferDialog(context, offer: offer),
                                    icon: const Icon(IconsaxPlusLinear.edit, size: 16),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.background,
                                      foregroundColor: AppColors.textPrimary,
                                      minimumSize: const Size(36, 36),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton.filledTonal(
                                    onPressed: () => _confirmDelete(context, offer, cubit),
                                    icon: const Icon(IconsaxPlusLinear.trash, size: 16),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.background,
                                      foregroundColor: AppColors.favorite,
                                      minimumSize: const Size(36, 36),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showOfferDialog(BuildContext context, {Offer? offer}) {
    final titleCtrl = TextEditingController(text: offer?.title ?? '');
    final orderCtrl = TextEditingController(text: '0');
    String? imageUrl = offer?.imageUrl;
    bool isUploading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer == null ? 'إضافة عرض جديد' : 'تعديل بيانات العرض',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Image Banner Picker
                  GestureDetector(
                    onTap: () async {
                      final cubit = context.read<AdminCubit>();
                      final picker = ImagePicker();
                      final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (img == null) return;

                      setModalState(() => isUploading = true);
                      final url = await cubit.uploadImage(img.path, folder: 'offers');
                      setModalState(() {
                        isUploading = false;
                        if (url != null) imageUrl = url;
                      });
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        image: imageUrl != null
                            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : imageUrl == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(IconsaxPlusLinear.gallery_add, size: 32, color: AppColors.brandDark),
                                    SizedBox(height: 6),
                                    Text('اضغط لاختيار صورة البانر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppFormField(
                    label: 'عنوان العرض / المشروع',
                    hint: 'مثال: عروض بروكر حصرية أو مرحلة جديدة',
                    controller: titleCtrl,
                    prefixIcon: IconsaxPlusLinear.discount_shape,
                  ),
                  const SizedBox(height: 12),

                  AppFormField(
                    label: 'الترتيب في العرض',
                    hint: '0',
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: IconsaxPlusLinear.sort,
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
                      final cubit = context.read<AdminCubit>();
                      final nav = Navigator.of(bottomSheetCtx);
                      await cubit.saveOffer(
                        id: offer?.id,
                        title: titleCtrl.text.trim(),
                        imageUrl: imageUrl,
                        order: order,
                      );
                      nav.pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('حفظ العرض'),
                  ),
                ],
              ),
            ));
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Offer offer, AdminCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف العرض'),
        content: Text('هل أنت متأكد من حذف "${offer.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.deleteOffer(offer.id);
    }
  }
}
