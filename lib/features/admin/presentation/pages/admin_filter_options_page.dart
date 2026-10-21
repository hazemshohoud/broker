import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/filter_options.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminFilterOptionsPage extends StatefulWidget {
  const AdminFilterOptionsPage({super.key});

  @override
  State<AdminFilterOptionsPage> createState() => _AdminFilterOptionsPageState();
}

class _AdminFilterOptionsPageState extends State<AdminFilterOptionsPage> {
  FilterOptions? _options;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().loadFilterOptions();
    });
  }

  void _saveDirect(AdminCubit cubit, FilterOptions updated) {
    setState(() => _options = updated);
    cubit.saveFilterOptions(updated);
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
        title: const Text(
          'خيارات التصفية والمناطق',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final currentOptions = _options ?? state.filterOptions;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Regions & Districts Section
              _SectionContainer(
                title: 'المحافظات والمناطق والأحياء',
                subtitle: 'تحدد قوائم الاختيار في تصفية وإضافة الكمبوندات (يتم الحفظ تلقائياً)',
                action: TextButton.icon(
                  onPressed: () => _addRegionDialog(context, cubit, currentOptions),
                  icon: const Icon(IconsaxPlusLinear.add_circle, size: 16),
                  label: const Text('إضافة منطقة'),
                ),
                children: currentOptions.regions.map((region) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(IconsaxPlusBold.location, size: 18, color: AppColors.brandDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                region.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(IconsaxPlusLinear.add, size: 16, color: AppColors.brandDark),
                              onPressed: () => _addDistrictDialog(context, cubit, currentOptions, region),
                              tooltip: 'إضافة حي / مركز',
                            ),
                            IconButton(
                              icon: const Icon(IconsaxPlusLinear.trash, size: 16, color: AppColors.favorite),
                              onPressed: () {
                                final updatedRegions = currentOptions.regions
                                    .where((r) => r.name != region.name)
                                    .toList();
                                _saveDirect(cubit, currentOptions.copyWith(regions: updatedRegions));
                              },
                              tooltip: 'حذف المنطقة',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: region.districts.map((district) {
                            return Chip(
                              label: Text(district, style: const TextStyle(fontSize: 11)),
                              backgroundColor: AppColors.surface,
                              deleteIcon: const Icon(Icons.close, size: 12),
                              onDeleted: () {
                                final updatedDistricts =
                                    region.districts.where((d) => d != district).toList();
                                final updatedRegions = currentOptions.regions.map((r) {
                                  if (r.name == region.name) {
                                    return Region(name: r.name, districts: updatedDistricts);
                                  }
                                  return r;
                                }).toList();
                                _saveDirect(cubit, currentOptions.copyWith(regions: updatedRegions));
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: AppColors.border),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Property Types Section
              _SectionContainer(
                title: 'أنواع العقارات والوحدات',
                subtitle: 'خيارات مثل: شقة، فيلا، روف، أرض...',
                action: TextButton.icon(
                  onPressed: () => _addPropertyTypeDialog(context, cubit, currentOptions),
                  icon: const Icon(IconsaxPlusLinear.add_circle, size: 16),
                  label: const Text('إضافة نوع'),
                ),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentOptions.propertyTypes.map((type) {
                      return Chip(
                        label: Text(type),
                        backgroundColor: AppColors.background,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          final updated = currentOptions.propertyTypes.where((t) => t != type).toList();
                          _saveDirect(cubit, currentOptions.copyWith(propertyTypes: updated));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Readiness Statuses
              _SectionContainer(
                title: 'حالات الاستلام والجاهزية',
                subtitle: 'خيارات مثل: جاهز، تحت الإنشاء',
                children: [
                  Wrap(
                    spacing: 8,
                    children: currentOptions.readinessStatuses.map((r) {
                      return Chip(
                        label: Text(r),
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Finishings
              _SectionContainer(
                title: 'خيارات التشطيب',
                subtitle: 'خيارات مثل: تشطيب كامل، نصف تشطيب، عضم',
                children: [
                  Wrap(
                    spacing: 8,
                    children: currentOptions.finishings.map((f) {
                      return Chip(
                        label: Text(f),
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.isSaving ? null : () => cubit.saveFilterOptions(currentOptions),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                      )
                    : const Text('حفظ خيارات التصفية بالكامل'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addRegionDialog(BuildContext context, AdminCubit cubit, FilterOptions options) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة منطقة جديدة'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'اسم المنطقة (مثال: شرق النيل)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final updated = List<Region>.from(options.regions)
                  ..add(Region(name: name, districts: const []));
                _saveDirect(cubit, options.copyWith(regions: updated));
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة وحفظ'),
          ),
        ],
      ),
    );
  }

  void _addDistrictDialog(
    BuildContext context,
    AdminCubit cubit,
    FilterOptions options,
    Region region,
  ) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('إضافة حي إلى ${region.name}'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'اسم الحي / المركز'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final dName = ctrl.text.trim();
              if (dName.isNotEmpty) {
                final updatedRegions = options.regions.map((r) {
                  if (r.name == region.name) {
                    final dList = List<String>.from(r.districts)..add(dName);
                    return Region(name: r.name, districts: dList);
                  }
                  return r;
                }).toList();
                _saveDirect(cubit, options.copyWith(regions: updatedRegions));
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة وحفظ'),
          ),
        ],
      ),
    );
  }

  void _addPropertyTypeDialog(
    BuildContext context,
    AdminCubit cubit,
    FilterOptions options,
  ) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة نوع عقار جديد'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'مثال: دوبلكس أو بنتهاوس'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty && !options.propertyTypes.contains(val)) {
                final updated = List<String>.from(options.propertyTypes)..add(val);
                _saveDirect(cubit, options.copyWith(propertyTypes: updated));
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة وحفظ'),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
