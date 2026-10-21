import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../../onboarding/domain/entities/onboarding_item.dart';

class AdminOnboardingPage extends StatefulWidget {
  const AdminOnboardingPage({super.key});

  @override
  State<AdminOnboardingPage> createState() => _AdminOnboardingPageState();
}

class _AdminOnboardingPageState extends State<AdminOnboardingPage> {
  final OnboardingRemoteDataSource _dataSource = OnboardingRemoteDataSourceImpl();

  void _showAddSlideSheet([OnboardingItem? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddOnboardingSheet(
        dataSource: _dataSource,
        initialItem: item,
      ),
    );
  }

  Future<void> _confirmDelete(OnboardingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الشريحة'),
        content: Text('هل أنت متأكد من حذف شريحة "${item.title}" من شاشات الترحيب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _dataSource.deleteOnboardingItem(item.id);
    }
  }

  Future<void> _seedDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة الـ 4 شاشات الافتراضية'),
        content: const Text(
          'سيتم إنشاء وتخزين الـ 4 شاشات الترحيبية الافتراضية في قاعدة البيانات لتتمكن من تعديلها وحذفها بسهولة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.brandDark),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('إضافة الآن'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _dataSource.seedDefaultItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'شاشات الترحيب (Onboarding)',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_right_3),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'تثبيت الشرائح الافتراضية',
            icon: const Icon(IconsaxPlusLinear.document_upload),
            onPressed: _seedDefaults,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        icon: const Icon(IconsaxPlusBold.add_circle, color: AppColors.brand),
        label: const Text(
          'إضافة شريحة جديدة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: () => _showAddSlideSheet(),
      ),
      body: StreamBuilder<List<OnboardingItem>>(
        stream: _dataSource.watchOnboardingItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      IconsaxPlusLinear.gallery_slash,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لا توجد شاشات ترحيبية في قاعدة البيانات حالياً',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'يمكنك إنشاء شاشات جديدة أو تثبيت الـ 4 شاشات الافتراضية بضغطة زر واحدة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.brandDark),
                      onPressed: _seedDefaults,
                      icon: const Icon(IconsaxPlusBold.add),
                      label: const Text('تثبيت الـ 4 شاشات الافتراضية الآن'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _OnboardingAdminCard(
                item: item,
                index: index + 1,
                onDelete: () => _confirmDelete(item),
              );
            },
          );
        },
      ),
    );
  }
}

class _OnboardingAdminCard extends StatelessWidget {
  const _OnboardingAdminCard({
    required this.item,
    required this.index,
    required this.onDelete,
  });

  final OnboardingItem item;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معاينة الصورة
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: AppNetworkImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.white30),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الشريحة رقم $index (الترتيب: ${item.order})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(IconsaxPlusLinear.trash, size: 18),
                  onPressed: onDelete,
                  tooltip: 'حذف الشريحة',
                ),
              ),
            ],
          ),

          // النصوص والمعلومات
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

class _AddOnboardingSheet extends StatefulWidget {
  const _AddOnboardingSheet({
    required this.dataSource,
    this.initialItem,
  });

  final OnboardingRemoteDataSource dataSource;
  final OnboardingItem? initialItem;

  @override
  State<_AddOnboardingSheet> createState() => _AddOnboardingSheetState();
}

class _AddOnboardingSheetState extends State<_AddOnboardingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  final _urlController = TextEditingController();

  XFile? _pickedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _titleController.text = widget.initialItem!.title;
      _descController.text = widget.initialItem!.description;
      _orderController.text = widget.initialItem!.order.toString();
      _urlController.text = widget.initialItem!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _orderController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _pickedFile = file);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار صورة من المعرض أو وضع رابط صورة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String finalImageUrl = _urlController.text.trim();

      // لو تم اختيار صورة محلية يتم رفعها إلى Cloudinary
      if (_pickedFile != null) {
        final cloudinary = CloudinaryService();
        final uploaded = await cloudinary.uploadImage(_pickedFile!.path);
        if (uploaded == null || uploaded.isEmpty) {
          throw Exception('فشل رفع الصورة إلى Cloudinary');
        }
        finalImageUrl = uploaded;
      }

      final order = int.tryParse(_orderController.text.trim()) ?? 1;

      await widget.dataSource.addOnboardingItem(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: finalImageUrl,
        order: order,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  'إضافة شريحة ترحيبية جديدة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),

                // اختيار ورفع الصورة
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedFile != null
                        ? Image.file(File(_pickedFile!.path), fit: BoxFit.cover)
                        : _urlController.text.isNotEmpty
                            ? AppNetworkImage(
                                url: _urlController.text,
                                fit: BoxFit.cover,
                                placeholder: const Center(
                                  child: Icon(IconsaxPlusLinear.image, size: 40),
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      IconsaxPlusBold.gallery_add,
                                      size: 38,
                                      color: AppColors.brandDark,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'انقر لاختيار صورة من المعرض',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 14),

                AppFormField(
                  label: 'عنوان الشريحة الرئيسية',
                  hint: 'مثال: أكبر شبكة مشروعات عقارية',
                  controller: _titleController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 12),

                AppFormField(
                  label: 'الوصف التوضيحي',
                  hint: 'اكتب تفاصيل ومزايا هذه الميزة للوسطاء...',
                  controller: _descController,
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'الوصف مطلوب' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppFormField(
                        label: 'الترتيب (1 - 4)',
                        hint: '1',
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppFormField(
                        label: 'أو رابط صورة مباشر (اختياري)',
                        hint: 'https://...',
                        controller: _urlController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _isUploading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'حفظ الشريحة في قاعدة البيانات',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
