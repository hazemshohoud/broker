import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/domain/entities/compound.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import 'admin_compound_edit_page.dart';

class AdminCompoundsPage extends StatefulWidget {
  const AdminCompoundsPage({super.key});

  @override
  State<AdminCompoundsPage> createState() => _AdminCompoundsPageState();
}

class _AdminCompoundsPageState extends State<AdminCompoundsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDeveloper;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'إدارة الكمبوندات والمشروعات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AdminCubit>(),
              child: const AdminCompoundEditPage(isNew: true),
            ),
          ),
        ),
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.primaryDark,
        icon: const Icon(IconsaxPlusBold.add_circle),
        label: const Text('إضافة كمبوند جديد', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = context.read<AdminCubit>();
          final compounds = state.compounds;
          final developers = state.developers;

          final filtered = compounds.where((c) {
            if (_selectedDeveloper != null && c.developerName != _selectedDeveloper) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchName = c.name.toLowerCase().contains(q);
              final matchDev = c.developerName.toLowerCase().contains(q);
              final matchLoc = c.location.toLowerCase().contains(q);
              if (!matchName && !matchDev && !matchLoc) return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search & Filter Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'البحث باسم الكمبوند، المطور أو المنطقة...',
                        prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    if (developers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('الكل'),
                              selected: _selectedDeveloper == null,
                              selectedColor: AppColors.brand.withValues(alpha: 0.2),
                              onSelected: (_) => setState(() => _selectedDeveloper = null),
                            ),
                            const SizedBox(width: 6),
                            ...developers.map((dev) {
                              final selected = _selectedDeveloper == dev.name;
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(end: 6),
                                child: ChoiceChip(
                                  label: Text(dev.name),
                                  selected: selected,
                                  selectedColor: AppColors.brand.withValues(alpha: 0.2),
                                  onSelected: (_) => setState(() => _selectedDeveloper = dev.name),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: () => cubit.loadCompounds(),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusLinear.building, size: 48, color: AppColors.textTertiary),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد كمبوندات مطابقة للبحث',
                                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final compound = filtered[index];
                            return _AdminCompoundCard(
                              compound: compound,
                              onEdit: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: AdminCompoundEditPage(compound: compound),
                                  ),
                                ),
                              ),
                              onDelete: () => _confirmDelete(context, compound, cubit),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Compound compound, AdminCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف الكمبوند'),
        content: Text('هل أنت متأكد من حذف "${compound.name}" نهائياً من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            child: const Text('حذف الكمبوند'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.deleteCompound(compound.id);
    }
  }
}

class _AdminCompoundCard extends StatelessWidget {
  const _AdminCompoundCard({
    required this.compound,
    required this.onEdit,
    required this.onDelete,
  });

  final Compound compound;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.background,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      compound.imageUrl != null
                          ? Image.network(compound.imageUrl!, fit: BoxFit.cover)
                          : const Icon(IconsaxPlusLinear.building_4, color: AppColors.textTertiary),
                      if (compound.allImages.length > 1)
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(IconsaxPlusBold.gallery, size: 8, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  '${compound.allImages.length}',
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            compound.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: compound.isProject
                                ? AppColors.brand.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            compound.isProject ? 'مشروع جديد' : 'عقار عادي',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: compound.isProject ? AppColors.brandDark : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${compound.developerName} · ${compound.location}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'العمولة: ${Formatters.price(compound.commission)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              IconButton.filledTonal(
                onPressed: onEdit,
                icon: const Icon(IconsaxPlusLinear.edit, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(IconsaxPlusLinear.trash, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.favorite,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...compound.propertyTypes.map((pt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(pt, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                );
              }),
              if (compound.readiness != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    compound.readiness!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brandDark),
                  ),
                ),
              if (compound.finishing != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    compound.finishing!,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
