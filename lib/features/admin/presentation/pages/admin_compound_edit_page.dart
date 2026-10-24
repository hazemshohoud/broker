import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../home/domain/entities/compound.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminCompoundEditPage extends StatefulWidget {
  const AdminCompoundEditPage({
    this.compound,
    this.isNew = false,
    super.key,
  });

  final Compound? compound;
  final bool isNew;

  @override
  State<AdminCompoundEditPage> createState() => _AdminCompoundEditPageState();
}

class _AmenityEntry {
  _AmenityEntry({required String name, required String distance})
      : nameController = TextEditingController(text: name),
        distanceController = TextEditingController(text: distance);

  final TextEditingController nameController;
  final TextEditingController distanceController;

  void dispose() {
    nameController.dispose();
    distanceController.dispose();
  }
}

class _AdminCompoundEditPageState extends State<AdminCompoundEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _devPriceController;
  late final TextEditingController _resalePriceController;
  late final TextEditingController _commissionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _locationController;
  late final TextEditingController _areaController;
  late final TextEditingController _deliveryDateController;
  late final TextEditingController _mapUrlController;

  final List<_AmenityEntry> _amenities = [];
  late final TextEditingController _faqWhyController;
  late final TextEditingController _faqDevController;
  late final TextEditingController _faqInvestController;
  late final TextEditingController _faqResaleController;

  String? _selectedDeveloper;
  String? _selectedRegion;
  String? _selectedDistrict;
  String? _readiness;
  String? _finishing;
  List<String> _propertyTypes = [];
  List<String> _imageUrls = [];
  bool _isProject = false;
  String? _projectImageUrl;
  bool _isUploadingProjectImage = false;
  bool _isUploadingImage = false;
  String? _uploadStatusText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.compound;
    _nameController = TextEditingController(text: c?.name ?? '');
    _devPriceController = TextEditingController(
      text: c != null ? c.developerStartPrice.toInt().toString() : '',
    );
    _resalePriceController = TextEditingController(
      text: c?.resaleStartPrice != null ? c!.resaleStartPrice!.toInt().toString() : '',
    );
    _commissionController = TextEditingController(
      text: c != null ? c.commission.toInt().toString() : '',
    );
    _phoneController = TextEditingController(text: c?.phone ?? '+201000000000');
    _whatsappController = TextEditingController(text: c?.whatsapp ?? c?.phone ?? '+201000000000');
    _locationController = TextEditingController(text: c?.location ?? '');
    _areaController = TextEditingController(text: c?.area ?? 'تبدأ من 120 م² إلى 350 م²');
    _deliveryDateController = TextEditingController(
      text: c?.deliveryDate ?? (c?.readiness == 'جاهز' ? 'استلام فوري' : '2026/2027'),
    );
    _mapUrlController = TextEditingController(
      text: c?.mapUrl ?? 'https://maps.google.com/?q=29.0667,31.0994',
    );

    final initialAmenities = c?.effectiveAmenities ?? const {
      'مستشفى': '1 كم',
      'جامعة': '1 كم',
      'مدرسة': '1 كم',
      'نادي': '1 كم',
      'سوبر ماركت': '1 كم',
      'عيادة': '1 كم',
      'صيدلية': '1 كم',
      'جيم': '1 كم',
      'كافيه او مطعم': '1 كم',
      'مساحات خضراء': '1 كم',
    };
    for (final entry in initialAmenities.entries) {
      _amenities.add(_AmenityEntry(name: entry.key, distance: entry.value));
    }

    final initialFaqs = c?.effectiveFaqs ?? const {};
    _faqWhyController = TextEditingController(
      text: initialFaqs['لماذا هذا العقار؟'] ??
          'يتميز المشروع بموقع استراتيجي بتصميم حديث ومساحات متنوعة وخدمات متكاملة.',
    );
    _faqDevController = TextEditingController(
      text: initialFaqs['معلومات عن المطور'] ??
          'شركة رائدة ذات سابقة أعمال قوية والتزام تام بمواعيد التسليم وجودة البناء.',
    );
    _faqInvestController = TextEditingController(
      text: initialFaqs['هل تصلح للاستثمار العقاري'] ??
          'نعم، فرصة استثمارية ممتازة بعائد إيجاري مجزٍ وارتفاع مستمر في القيمة السوقية.',
    );
    _faqResaleController = TextEditingController(
      text: initialFaqs['خدمة إعادة البيع'] ??
          'نوفر خدمة إعادة بيع وتأجير سريعة ومضمونة لجميع عملائنا.',
    );

    _selectedDeveloper = c?.developerName;
    _selectedRegion = c?.region;
    _selectedDistrict = c?.district;
    _readiness = c?.readiness ?? 'جاهز';
    _finishing = c?.finishing ?? 'تشطيب كامل';
    _propertyTypes = List.from(c?.propertyTypes ?? ['شقة', 'فيلا']);
    _imageUrls = List.from(c?.allImages ?? []);
    _isProject = c?.isProject ?? false;
    _projectImageUrl = c?.projectImageUrl;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadFilterOptions();
      context.read<AdminCubit>().loadDevelopers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _devPriceController.dispose();
    _resalePriceController.dispose();
    _commissionController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _deliveryDateController.dispose();
    _mapUrlController.dispose();
    for (final item in _amenities) {
      item.dispose();
    }
    _faqWhyController.dispose();
    _faqDevController.dispose();
    _faqInvestController.dispose();
    _faqResaleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImages() async {
    if (_imageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الوصول للحد الأقصى (5 صور للعقار)')),
      );
      return;
    }

    final picker = ImagePicker();
    final availableSlots = 5 - _imageUrls.length;

    // Show source choice dialog (Gallery multi-pick, single pick, Camera, or direct URL)
    final source = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة صور للعقار (متبقي $availableSlots من 5)',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.gallery, color: AppColors.brandDark),
                title: const Text('اختيار من المعرض (عدة صور)'),
                onTap: () => Navigator.of(ctx).pop('gallery_multi'),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.gallery_add, color: AppColors.brandDark),
                title: const Text('اختيار من المعرض (صورة واحدة)'),
                onTap: () => Navigator.of(ctx).pop('gallery_single'),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.camera, color: AppColors.brandDark),
                title: const Text('التقاط بالكاميرا'),
                onTap: () => Navigator.of(ctx).pop('camera'),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.link, color: AppColors.brandDark),
                title: const Text('إدخال رابط صورة مباشرة (URL)'),
                onTap: () => Navigator.of(ctx).pop('url'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    if (source == 'url') {
      if (!mounted) return;
      final urlCtrl = TextEditingController();
      final enteredUrl = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('إضافة رابط صورة مباشر'),
          content: TextField(
            controller: urlCtrl,
            decoration: const InputDecoration(
              hintText: 'https://images.unsplash.com/...',
              labelText: 'رابط الصورة',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(urlCtrl.text.trim()),
              child: const Text('إضافة'),
            ),
          ],
        ),
      );

      if (enteredUrl != null && enteredUrl.isNotEmpty && mounted) {
        setState(() {
          if (_imageUrls.length < 5) {
            _imageUrls.add(enteredUrl);
          }
        });
      }
      return;
    }

    try {
      List<XFile> pickedFiles = [];
      if (source == 'camera') {
        final shot = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
        if (shot != null) pickedFiles.add(shot);
      } else if (source == 'gallery_single') {
        final single = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (single != null) pickedFiles.add(single);
      } else {
        pickedFiles = await picker.pickMultiImage(imageQuality: 85);
        if (pickedFiles.isEmpty) {
          final single = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
          if (single != null) pickedFiles.add(single);
        }
      }

      if (pickedFiles.isEmpty) return;

      if (pickedFiles.length > availableSlots) {
        pickedFiles = pickedFiles.take(availableSlots).toList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('الحد الأقصى 5 صور، سيتم رفع أول $availableSlots صور فقط')),
          );
        }
      }

      if (!mounted) return;
      final cubit = context.read<AdminCubit>();
      setState(() => _isUploadingImage = true);

      for (var i = 0; i < pickedFiles.length; i++) {
        if (!mounted) break;
        setState(() {
          _uploadStatusText = 'جاري رفع صورة ${i + 1} من ${pickedFiles.length}...';
        });
        final uploadedUrl = await cubit.uploadImage(
          pickedFiles[i].path,
          folder: 'compounds',
        );
        if (uploadedUrl != null && mounted) {
          setState(() {
            if (_imageUrls.length < 5) {
              _imageUrls.add(uploadedUrl);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء رفع الصور: $e'),
            backgroundColor: AppColors.favorite,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _uploadStatusText = null;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _setPrimaryImage(int index) {
    if (index <= 0 || index >= _imageUrls.length) return;
    setState(() {
      final img = _imageUrls.removeAt(index);
      _imageUrls.insert(0, img);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعيينها كصورة رئيسية للعقار')),
    );
  }

  Future<void> _pickAndUploadProjectImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختيار صورة بانر المشروع',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.camera, color: AppColors.brandDark),
                title: const Text('التقاط بالكاميرا'),
                onTap: () => Navigator.of(ctx).pop('camera'),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.gallery, color: AppColors.brandDark),
                title: const Text('اختيار من المعرض'),
                onTap: () => Navigator.of(ctx).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(IconsaxPlusLinear.link_2, color: AppColors.brandDark),
                title: const Text('إدخال رابط صورة مباشرة'),
                onTap: () => Navigator.of(ctx).pop('link'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    if (source == 'link') {
      final ctrl = TextEditingController(text: _projectImageUrl ?? '');
      final enteredUrl = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('إدخال رابط صورة المشروع'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'https://...',
              labelText: 'رابط الصورة المباشر',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(ctrl.text.trim()),
              child: const Text('استخدام'),
            ),
          ],
        ),
      );
      if (enteredUrl != null && enteredUrl.isNotEmpty && mounted) {
        setState(() => _projectImageUrl = enteredUrl);
      }
      return;
    }

    try {
      final shot = await picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (shot == null || !mounted) return;

      setState(() => _isUploadingProjectImage = true);
      final uploadedUrl = await context.read<AdminCubit>().uploadImage(
        shot.path,
        folder: 'projects',
      );
      if (uploadedUrl != null && mounted) {
        setState(() => _projectImageUrl = uploadedUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء رفع صورة المشروع: $e'),
            backgroundColor: AppColors.favorite,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingProjectImage = false);
      }
    }
  }

  Future<void> _showAddRegionDialog(BuildContext context, FilterOptions options) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة منطقة / محافظة جديدة'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'مثال: بني سويف أو القاهرة الجديدة',
            labelText: 'اسم المنطقة',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                if (!options.regions.any((r) => r.name == name)) {
                  final updated = List<Region>.from(options.regions)..add(Region(name: name, districts: const []));
                  final newOptions = options.copyWith(regions: updated);
                  await context.read<AdminCubit>().saveFilterOptions(newOptions);
                  if (mounted) {
                    setState(() {
                      _selectedRegion = name;
                      _selectedDistrict = null;
                    });
                  }
                }
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة وحفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDistrictDialog(BuildContext context, FilterOptions options, String regionName) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('إضافة حي / مركز في $regionName'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'مثال: حي الزهور أو شرق النيل',
            labelText: 'اسم الحي / المركز',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final dName = ctrl.text.trim();
              if (dName.isNotEmpty) {
                final updatedRegions = options.regions.map((r) {
                  if (r.name == regionName) {
                    final dList = List<String>.from(r.districts);
                    if (!dList.contains(dName)) dList.add(dName);
                    return Region(name: r.name, districts: dList);
                  }
                  return r;
                }).toList();
                final newOptions = options.copyWith(regions: updatedRegions);
                await context.read<AdminCubit>().saveFilterOptions(newOptions);
                if (mounted) {
                  setState(() {
                    _selectedDistrict = dName;
                  });
                }
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة وحفظ'),
          ),
        ],
      ),
    );
  }

  void _addAmenity([String name = '', String distance = '1 كم']) {
    setState(() {
      _amenities.add(_AmenityEntry(name: name, distance: distance));
    });
  }

  void _removeAmenity(int index) {
    setState(() {
      final removed = _amenities.removeAt(index);
      removed.dispose();
    });
  }

  void _showAddAmenityDialog(BuildContext context, FilterOptions filterOptions) {
    final existingNames = _amenities.map((a) => a.nameController.text.trim()).toSet();
    final availableSuggestions = filterOptions.amenities
        .where((a) => !existingNames.contains(a))
        .toList();

    final nameController = TextEditingController();
    final distanceController = TextEditingController(text: '1 كم');

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(IconsaxPlusBold.routing, color: AppColors.brandDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'إضافة مرفق / خدمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (availableSuggestions.isNotEmpty) ...[
                      const Text(
                        'اختر من المرفقات الشائعة:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: availableSuggestions.map((suggestion) {
                          final isSelected = nameController.text.trim() == suggestion;
                          return ChoiceChip(
                            label: Text(suggestion),
                            selected: isSelected,
                            selectedColor: AppColors.brand,
                            backgroundColor: AppColors.background,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? AppColors.brand : AppColors.borderLight,
                              ),
                            ),
                            onSelected: (_) {
                              setDialogState(() {
                                nameController.text = suggestion;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 10),
                    ],
                    AppFormField(
                      label: 'اسم المرفق',
                      hint: 'مثال: جيم، مستشفى، محطة مترو...',
                      controller: nameController,
                      prefixIcon: IconsaxPlusLinear.routing,
                    ),
                    const SizedBox(height: 12),
                    AppFormField(
                      label: 'المسافة التقديرية',
                      hint: 'مثال: 500 م، 1 كم، داخل المشروع...',
                      controller: distanceController,
                      prefixIcon: IconsaxPlusLinear.location,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final dist = distanceController.text.trim();
                    if (name.isNotEmpty) {
                      _addAmenity(name, dist.isNotEmpty ? dist : '1 كم');
                      Navigator.of(dialogCtx).pop();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDeveloper == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المطور العقاري')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final region = _selectedRegion ?? 'بني سويف';
    final district = _selectedDistrict ?? 'المدينة';
    final location = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : '$district، $region';

    final devState = context.read<AdminCubit>().state;
    final matchedDev = devState.developers.where((d) => d.name == _selectedDeveloper).firstOrNull;
    final developerLogoUrl = matchedDev?.logoUrl ?? widget.compound?.developerLogoUrl;

    final Map<String, String> savedAmenities = {};
    for (final item in _amenities) {
      final name = item.nameController.text.trim();
      final dist = item.distanceController.text.trim();
      if (name.isNotEmpty) {
        savedAmenities[name] = dist.isNotEmpty ? dist : '1 كم';
      }
    }
    final savedFaqs = {
      'لماذا هذا العقار؟': _faqWhyController.text.trim(),
      'معلومات عن المطور': _faqDevController.text.trim(),
      'هل تصلح للاستثمار العقاري': _faqInvestController.text.trim(),
      'خدمة إعادة البيع': _faqResaleController.text.trim(),
    };

    final compound = Compound(
      id: widget.isNew
          ? _nameController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-')
          : (widget.compound?.id ?? ''),
      name: _nameController.text.trim(),
      location: location,
      developerName: _selectedDeveloper!,
      developerLogoUrl: developerLogoUrl,
      developerStartPrice: double.tryParse(_devPriceController.text.trim()) ?? 0.0,
      resaleStartPrice: _resalePriceController.text.trim().isNotEmpty
          ? double.tryParse(_resalePriceController.text.trim())
          : null,
      commission: double.tryParse(_commissionController.text.trim()) ?? 0.0,
      propertyTypes: _propertyTypes.isNotEmpty ? _propertyTypes : ['شقة'],
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      imageUrl: _imageUrls.isNotEmpty
          ? _imageUrls.first
          : (_projectImageUrl != null && _projectImageUrl!.trim().isNotEmpty
              ? _projectImageUrl!.trim()
              : null),
      imageUrls: _imageUrls.isNotEmpty
          ? _imageUrls
          : (_projectImageUrl != null && _projectImageUrl!.trim().isNotEmpty
              ? [_projectImageUrl!.trim()]
              : const <String>[]),
      isProject: _isProject,
      projectImageUrl: _projectImageUrl,
      region: region,
      district: district,
      readiness: _readiness,
      finishing: _finishing,
      area: _areaController.text.trim(),
      deliveryDate: _deliveryDateController.text.trim(),
      mapUrl: _mapUrlController.text.trim(),
      amenities: savedAmenities,
      faqs: savedFaqs,
      attachments: widget.compound?.effectiveAttachments,
    );

    final success = await context.read<AdminCubit>().saveCompound(
      compound,
      isNew: widget.isNew,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

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
        title: Text(
          widget.isNew ? 'إضافة كمبوند جديد' : 'تعديل بيانات الكمبوند',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final developers = state.developers;
          final filterOptions = state.filterOptions;
          final regions = filterOptions.regions;

          // Available districts for current region
          final currentRegionObj = regions.where((r) => r.name == _selectedRegion).firstOrNull;
          final availableDistricts = currentRegionObj?.districts ??
              (regions.isNotEmpty ? regions.first.districts : <String>[]);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Multi-Image Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isProject
                          ? 'صور بروفايل المشروع (المعرض الداخلي)'
                          : 'صور العقار (المعرض الداخلي)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _imageUrls.length == 5
                            ? AppColors.brand.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _imageUrls.length == 5 ? AppColors.brand : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '${_imageUrls.length} من 5 صور',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _imageUrls.length == 5 ? AppColors.brandDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Uploading indicator
                if (_isUploadingImage)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.brand.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.brandDark),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _uploadStatusText ?? 'جاري رفع الصور إلى السحابة...',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Empty state or images gallery
                if (_imageUrls.isEmpty)
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadImages,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(IconsaxPlusLinear.gallery_add, size: 44, color: AppColors.brandDark),
                          const SizedBox(height: 10),
                          Text(
                            _isProject
                                ? 'اضغط لإضافة صور بروفايل المشروع (حتى 5 صور)'
                                : 'اضغط لإضافة صور العقار (حتى 5 صور)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isProject
                                ? 'تظهر هذه الصور داخل شاشة تفاصيل المشروع للتنقل اليدوي بينها'
                                : 'يمكنك اختيار صور متعددة من المعرض أو التصوير',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Primary Image Banner
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          image: DecorationImage(
                            image: NetworkImage(_imageUrls.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brand.withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(IconsaxPlusBold.star_1, size: 13, color: AppColors.brand),
                              SizedBox(width: 4),
                              Text(
                                'الصورة الرئيسية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                            onPressed: () => _removeImage(0),
                            tooltip: 'حذف الصورة',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Thumbnails Row & Add Button
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length + (_imageUrls.length < 5 ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        // "Add More" Button
                        if (index == _imageUrls.length) {
                          return GestureDetector(
                            onTap: _isUploadingImage ? null : _pickAndUploadImages,
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.brand, width: 1.5),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconsaxPlusLinear.add_circle, color: AppColors.brandDark, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    'إضافة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brandDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final url = _imageUrls[index];
                        final isPrimary = index == 0;

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: isPrimary ? null : () => _setPrimaryImage(index),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isPrimary ? AppColors.brand : AppColors.border,
                                    width: isPrimary ? 2.5 : 1,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(url),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (!isPrimary)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _setPrimaryImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'رئيسية',
                                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 2,
                              left: 2,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Display Destination Form (عقار عادي أو مشروع جديد)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isProject
                          ? AppColors.brand.withValues(alpha: 0.6)
                          : AppColors.border,
                      width: _isProject ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(IconsaxPlusBold.category, size: 18, color: AppColors.brandDark),
                          SizedBox(width: 8),
                          Text(
                            'مكان ونوع العرض في التطبيق',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isProject = false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: !_isProject ? const Color(0xFF111111) : AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !_isProject ? Colors.black : AppColors.border,
                                    width: !_isProject ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      IconsaxPlusBold.building_4,
                                      size: 16,
                                      color: !_isProject ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'عقار عادي',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: !_isProject ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isProject = true),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _isProject ? AppColors.brand : AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isProject ? AppColors.brand : AppColors.border,
                                    width: _isProject ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      IconsaxPlusBold.star_1,
                                      size: 16,
                                      color: _isProject ? AppColors.primaryDark : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'مشروع جديد',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: _isProject ? AppColors.primaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isProject
                            ? 'سيتم عرض هذا العقار كبانر في قسم "المشروعات الجديدة" بالصفحة الرئيسية وعند الضغط عليه يفتح بروفايل العقار'
                            : 'سيتم عرض هذا العقار ضمن قائمة "كمبوندات في مصر" العادية',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _isProject ? AppColors.brandDark : AppColors.textSecondary,
                        ),
                      ),
                      if (_isProject) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'صورة بانر المشروع (المشاريع الجديدة)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_projectImageUrl != null)
                              TextButton.icon(
                                onPressed: () => setState(() => _projectImageUrl = null),
                                icon: const Icon(Icons.close, size: 14, color: AppColors.favorite),
                                label: const Text('إزالة', style: TextStyle(color: AppColors.favorite, fontSize: 11)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickAndUploadProjectImage,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _projectImageUrl != null ? AppColors.brand : AppColors.border,
                                width: _projectImageUrl != null ? 1.5 : 1.0,
                              ),
                              image: _projectImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_projectImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _isUploadingProjectImage
                                ? const Center(child: CircularProgressIndicator())
                                : _projectImageUrl == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            IconsaxPlusLinear.image,
                                            size: 32,
                                            color: AppColors.brand.withValues(alpha: 0.8),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'اضغط لرفع صورة بانر المشروع (أفقية)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'إذا تركت فارغة سيتم استخدام أول صورة من صور العقار تلقائياً',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit, size: 13, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text(
                                                'تغيير الصورة',
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
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(IconsaxPlusBold.gallery, size: 16, color: AppColors.brandDark),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'صور بروفايل المشروع الداخلية',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _imageUrls.isNotEmpty ? AppColors.brand.withValues(alpha: 0.2) : Colors.black12,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_imageUrls.length} من 5 صور',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _imageUrls.isNotEmpty ? AppColors.brandDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'تظهر هذه الصور في شاشة بروفايل المشروع عند الضغط عليه من الصفحة الرئيسية للتنقل بينها يدوياً',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              if (_imageUrls.isNotEmpty)
                                SizedBox(
                                  height: 64,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _imageUrls.length + (_imageUrls.length < 5 ? 1 : 0),
                                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      if (idx == _imageUrls.length) {
                                        return InkWell(
                                          onTap: _isUploadingImage ? null : _pickAndUploadImages,
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.brand, width: 1.5),
                                            ),
                                            child: const Icon(Icons.add, color: AppColors.brandDark),
                                          ),
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(_imageUrls[idx], width: 60, height: 64, fit: BoxFit.cover),
                                      );
                                    },
                                  ),
                                )
                              else
                                OutlinedButton.icon(
                                  onPressed: _isUploadingImage ? null : _pickAndUploadImages,
                                  icon: const Icon(IconsaxPlusLinear.gallery_add, size: 16),
                                  label: const Text('إضافة صور لبروفايل المشروع (حتى 5 صور)'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.brandDark,
                                    side: const BorderSide(color: AppColors.brand),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                AppFormField(
                  label: 'اسم الكمبوند / المشروع',
                  hint: 'مثال: وان هايد بارك',
                  controller: _nameController,
                  prefixIcon: IconsaxPlusLinear.building_4,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'اكتب اسم الكمبوند' : null,
                ),
                const SizedBox(height: 16),

                // Developer Dropdown
                const Text(
                  'المطور العقاري',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: developers.any((d) => d.name == _selectedDeveloper) ? _selectedDeveloper : null,
                      isExpanded: true,
                      hint: const Text('اختر المطور العقاري'),
                      items: developers.map((d) {
                        return DropdownMenuItem(value: d.name, child: Text(d.name));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDeveloper = val;
                          if (val != null) {
                            final matchedDevs = developers.where((d) => d.name == val);
                            if (matchedDevs.isNotEmpty) {
                              final dev = matchedDevs.first;
                              final p = dev.phone?.trim();
                              if (p != null && p.isNotEmpty) {
                                _phoneController.text = p;
                              }
                              final w = dev.whatsapp?.trim();
                              if (w != null && w.isNotEmpty) {
                                _whatsappController.text = w;
                              }
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Region & District Row
                Row(
                  children: [
                    // Region
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المنطقة',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              GestureDetector(
                                onTap: () => _showAddRegionDialog(context, filterOptions),
                                child: const Row(
                                  children: [
                                    Icon(IconsaxPlusLinear.add_circle, size: 14, color: AppColors.brandDark),
                                    SizedBox(width: 3),
                                    Text(
                                      'إضافة',
                                      style: TextStyle(fontSize: 11, color: AppColors.brandDark, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: regions.any((r) => r.name == _selectedRegion) ? _selectedRegion : null,
                                isExpanded: true,
                                hint: const Text('المنطقة'),
                                items: regions.map((r) {
                                  return DropdownMenuItem(value: r.name, child: Text(r.name));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedRegion = val;
                                    _selectedDistrict = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // District
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الحي / المركز',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              if (_selectedRegion != null)
                                GestureDetector(
                                  onTap: () => _showAddDistrictDialog(context, filterOptions, _selectedRegion!),
                                  child: const Row(
                                    children: [
                                      Icon(IconsaxPlusLinear.add_circle, size: 14, color: AppColors.brandDark),
                                      SizedBox(width: 3),
                                      Text(
                                        'إضافة',
                                        style: TextStyle(fontSize: 11, color: AppColors.brandDark, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : null,
                                isExpanded: true,
                                hint: const Text('الحي'),
                                items: availableDistricts.map((d) {
                                  return DropdownMenuItem(value: d, child: Text(d));
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedDistrict = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Details
                AppFormField(
                  label: 'الموقع التفصيلي (اختياري)',
                  hint: 'مثال: بجوار الجامعة، طريق الكورنيش',
                  controller: _locationController,
                  prefixIcon: IconsaxPlusLinear.location,
                ),
                const SizedBox(height: 16),

                // Prices & Commission Row
                Row(
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: 'سعر المطور (ج.م)',
                        hint: '6800000',
                        controller: _devPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (val) => (val == null || val.isEmpty) ? 'اكتب السعر' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppFormField(
                        label: 'سعر إعادة البيع (ج.م)',
                        hint: 'اختياري',
                        controller: _resalePriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: 'قيمة العمولة (ج.م)',
                        hint: '170000',
                        controller: _commissionController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (val) => (val == null || val.isEmpty) ? 'اكتب العمولة' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppFormField(
                        label: 'رقم هاتف المبيعات',
                        hint: '+201000000000',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppFormField(
                  label: 'رقم الواتساب للتواصل والصفقات',
                  hint: '+201000000000',
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: IconsaxPlusLinear.message,
                ),
                const SizedBox(height: 20),

                // Property Types Multi-Select Chips
                const Text(
                  'أنواع الوحدات المتاحة',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (filterOptions.propertyTypes.isNotEmpty
                          ? filterOptions.propertyTypes
                          : ['شقة', 'فيلا', 'أرض', 'مكتب', 'محل', 'منزل', 'روف'])
                      .map((type) {
                    final selected = _propertyTypes.contains(type);
                    return FilterChip(
                      label: Text(type),
                      selected: selected,
                      selectedColor: AppColors.brand.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.brandDark,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        color: selected ? AppColors.brandDark : AppColors.textSecondary,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _propertyTypes.add(type);
                          } else {
                            _propertyTypes.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Readiness & Finishing
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حالة الاستلام',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _readiness,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'جاهز', child: Text('جاهز')),
                                  DropdownMenuItem(value: 'تحت الإنشاء', child: Text('تحت الإنشاء')),
                                ],
                                onChanged: (val) => setState(() => _readiness = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التشطيب',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _finishing,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'تشطيب كامل', child: Text('تشطيب كامل')),
                                  DropdownMenuItem(value: 'نصف تشطيب', child: Text('نصف تشطيب')),
                                  DropdownMenuItem(value: 'عضم', child: Text('عضم')),
                                ],
                                onChanged: (val) => setState(() => _finishing = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Area & Delivery Date
                Row(
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: 'المساحة',
                        hint: 'تبدأ من 120 م² إلى 350 م²',
                        controller: _areaController,
                        prefixIcon: IconsaxPlusLinear.ruler,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppFormField(
                        label: 'تاريخ الاستلام',
                        hint: 'فوري أو 2026',
                        controller: _deliveryDateController,
                        prefixIcon: IconsaxPlusLinear.calendar,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Map URL / coordinates
                AppFormField(
                  label: 'رابط خريطة الموقع على Google Maps',
                  hint: 'https://maps.google.com/?q=...',
                  controller: _mapUrlController,
                  prefixIcon: IconsaxPlusLinear.map_1,
                ),
                const SizedBox(height: 24),

                // Nearby Amenities (المرفقات والخدمات القريبة)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'الخدمات القريبة والمرفقات',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brand.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_amenities.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'المسافات التقديرية (1 كم، 500 م)، يمكنك إضافة أو حذف أي مرفق',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAmenityDialog(context, filterOptions),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.brandDark,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(IconsaxPlusLinear.add_circle, size: 16),
                      label: const Text('إضافة مرفق', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quick add chips for suggestions
                Builder(
                  builder: (_) {
                    final existingNames = _amenities.map((a) => a.nameController.text.trim()).toSet();
                    final remainingSuggestions = filterOptions.amenities
                        .where((a) => !existingNames.contains(a))
                        .take(6)
                        .toList();

                    if (remainingSuggestions.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: remainingSuggestions.map((s) {
                          return ActionChip(
                            avatar: const Icon(IconsaxPlusLinear.add, size: 13, color: AppColors.brandDark),
                            label: Text(s),
                            labelStyle: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.borderLight),
                            ),
                            onPressed: () => _addAmenity(s, '1 كم'),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                if (_amenities.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        const Icon(IconsaxPlusLinear.routing, size: 32, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        const Text(
                          'لم يتم إضافة أي مرافق لهذا المشروع بعد',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => _showAddAmenityDialog(context, filterOptions),
                          child: const Text('اضغط هنا لإضافة خدمات ومرافق'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _amenities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _amenities[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.brand.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                IconsaxPlusLinear.routing,
                                size: 16,
                                color: AppColors.brandDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // اسم المرفق
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: item.nameController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'اسم المرفق (جيم، مستشفى...)',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              height: 22,
                              width: 1,
                              color: AppColors.borderLight,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            // المسافة
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: item.distanceController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'المسافة (1 كم)',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            // زر حذف المرفق
                            IconButton(
                              icon: const Icon(
                                IconsaxPlusLinear.trash,
                                size: 17,
                                color: AppColors.favorite,
                              ),
                              tooltip: 'حذف المرفق',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _removeAmenity(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // FAQs Section
                const Text(
                  'الأسئلة الشائعة حول المشروع (Accordion)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                AppFormField(
                  label: 'لماذا هذا العقار؟',
                  hint: 'مميزات المشروع وتفاصيله الحصرية...',
                  controller: _faqWhyController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AppFormField(
                  label: 'معلومات عن المطور',
                  hint: 'نبذة عن شركة التطوير وسابقة أعمالها...',
                  controller: _faqDevController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AppFormField(
                  label: 'هل تصلح للاستثمار العقاري؟',
                  hint: 'العائد الإيجاري ومميزات الاستثمار...',
                  controller: _faqInvestController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AppFormField(
                  label: 'خدمة إعادة البيع',
                  hint: 'تفاصيل دعم وتسهيل إعادة البيع...',
                  controller: _faqResaleController,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                        )
                      : Text(widget.isNew ? 'إضافة الكمبوند وحفظه' : 'حفظ التعديلات'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
