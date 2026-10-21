import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../home/domain/entities/developer.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminDevelopersPage extends StatelessWidget {
  const AdminDevelopersPage({super.key});

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
          'شركات التطوير العقاري',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDeveloperDialog(context, cubit: context.read<AdminCubit>()),
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.primaryDark,
        icon: const Icon(IconsaxPlusBold.add_circle),
        label: const Text('إضافة شركة / مطور', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.favorite),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final developers = state.developers;

          return RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () => cubit.loadDevelopers(),
            child: developers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Text(
                          'لا يوجد مطورين حالياً، اضغط على إضافة شركة بالأسفل',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: developers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dev = developers[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.background,
                                  backgroundImage: dev.logoUrl != null ? NetworkImage(dev.logoUrl!) : null,
                                  child: dev.logoUrl == null
                                      ? Text(
                                          dev.name.isNotEmpty ? dev.name.characters.first : 'م',
                                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandDark),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dev.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (dev.order > 0)
                                        Text(
                                          'ترتيب العرض: ${dev.order}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () => _showDeveloperDialog(context, developer: dev, cubit: cubit),
                                  icon: const Icon(IconsaxPlusLinear.edit, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.background,
                                    foregroundColor: AppColors.textPrimary,
                                    minimumSize: const Size(36, 36),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton.filledTonal(
                                  onPressed: () => _confirmDelete(context, dev, cubit),
                                  icon: const Icon(IconsaxPlusLinear.trash, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.background,
                                    foregroundColor: AppColors.favorite,
                                    minimumSize: const Size(36, 36),
                                  ),
                                ),
                              ],
                            ),
                            if (dev.description != null && dev.description!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                dev.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            if ((dev.phone != null && dev.phone!.isNotEmpty) ||
                                (dev.whatsapp != null && dev.whatsapp!.isNotEmpty)) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (dev.phone != null && dev.phone!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.borderLight),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(IconsaxPlusBold.call, size: 12, color: AppColors.brandDark),
                                          const SizedBox(width: 4),
                                          Text(
                                            dev.phone!,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (dev.whatsapp != null && dev.whatsapp!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(IconsaxPlusBold.message, size: 12, color: Color(0xFF15803D)),
                                          const SizedBox(width: 4),
                                          Text(
                                            dev.whatsapp!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF15803D),
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
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

  void _showDeveloperDialog(
    BuildContext context, {
    Developer? developer,
    required AdminCubit cubit,
  }) {
    final nameCtrl = TextEditingController(text: developer?.name ?? '');
    final aboutCtrl = TextEditingController(text: developer?.description ?? '');
    final phoneCtrl = TextEditingController(text: developer?.phone ?? '');
    final whatsappCtrl = TextEditingController(text: developer?.whatsapp ?? '');
    final orderCtrl = TextEditingController(text: (developer?.order ?? 0).toString());
    String? logoUrl = developer?.logoUrl;
    bool isUploading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final bottomInset = MediaQuery.viewInsetsOf(dialogCtx).bottom;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        developer == null ? 'إضافة شركة / مطور عقاري' : 'تعديل بيانات الشركة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Logo Picker
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                                if (img == null) return;

                                setModalState(() => isUploading = true);
                                final url = await cubit.uploadImage(img.path, folder: 'developers');
                                setModalState(() {
                                  isUploading = false;
                                  if (url != null) logoUrl = url;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                  image: logoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(logoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: isUploading
                                    ? const Padding(
                                        padding: EdgeInsets.all(22),
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : logoUrl == null
                                        ? const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(IconsaxPlusLinear.gallery_add, size: 24, color: AppColors.brandDark),
                                              SizedBox(height: 2),
                                              Text('الشعار', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                            ],
                                          )
                                        : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.brand,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(IconsaxPlusBold.edit, size: 12, color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      AppFormField(
                        label: 'اسم الشركة / المطور العقاري',
                        hint: 'مثال: شركة إعمار مصر أو سوديك',
                        controller: nameCtrl,
                        prefixIcon: IconsaxPlusLinear.buildings,
                      ),
                      const SizedBox(height: 12),

                      // About / Description
                      AppFormField(
                        label: 'نبذة عن الشركة',
                        hint: 'معلومات عن سابقة أعمال وتاريخ ومميزات الشركة...',
                        controller: aboutCtrl,
                        maxLines: 3,
                        prefixIcon: IconsaxPlusLinear.document_text,
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      AppFormField(
                        label: 'رقم الهاتف المباشر',
                        hint: '01xxxxxxxxx أو +201xxxxxxxxx',
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: IconsaxPlusLinear.call,
                      ),
                      const SizedBox(height: 12),

                      // WhatsApp
                      AppFormField(
                        label: 'رقم الواتساب',
                        hint: '01xxxxxxxxx أو +201xxxxxxxxx',
                        controller: whatsappCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: IconsaxPlusLinear.message,
                      ),
                      const SizedBox(height: 12),

                      // Order
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
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يرجى إدخال اسم الشركة')),
                            );
                            return;
                          }
                          final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
                          final nav = Navigator.of(bottomSheetCtx);
                          await cubit.saveDeveloper(
                            id: developer?.id,
                            name: name,
                            logoUrl: logoUrl,
                            description: aboutCtrl.text.trim().isNotEmpty ? aboutCtrl.text.trim() : null,
                            phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                            whatsapp: whatsappCtrl.text.trim().isNotEmpty ? whatsappCtrl.text.trim() : null,
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
                        child: const Text('حفظ بيانات الشركة'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Developer dev, AdminCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف المطور العقاري'),
        content: Text('هل أنت متأكد من حذف "${dev.name}"؟'),
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
      await cubit.deleteDeveloper(dev.id);
    }
  }
}
