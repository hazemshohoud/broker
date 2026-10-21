import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/launcher.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_top_header.dart';
import '../../../../core/widgets/whatsapp_logo.dart';
import '../../domain/entities/developer.dart';
import '../cubit/home_cubit.dart';

class DevelopersPage extends StatelessWidget {
  const DevelopersPage({super.key, this.initialDeveloperName});

  final String? initialDeveloperName;

  static Future<void> open(BuildContext context, {String? initialDeveloperName}) {
    HomeCubit? cubit;
    try {
      cubit = BlocProvider.of<HomeCubit>(context, listen: false);
    } catch (_) {
      cubit = null;
    }

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => cubit != null
            ? BlocProvider.value(
                value: cubit,
                child: DevelopersPage(initialDeveloperName: initialDeveloperName),
              )
            : BlocProvider(
                create: (_) => sl<HomeCubit>()..load(),
                child: DevelopersPage(initialDeveloperName: initialDeveloperName),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        HomeCubit? cubit;
        try {
          cubit = BlocProvider.of<HomeCubit>(ctx, listen: false);
        } catch (_) {
          cubit = null;
        }

        if (cubit != null) {
          return _DevelopersView(initialDeveloperName: initialDeveloperName);
        }

        return BlocProvider(
          create: (_) => sl<HomeCubit>()..load(),
          child: _DevelopersView(initialDeveloperName: initialDeveloperName),
        );
      },
    );
  }
}

class _DevelopersView extends StatefulWidget {
  const _DevelopersView({this.initialDeveloperName});

  final String? initialDeveloperName;

  @override
  State<_DevelopersView> createState() => _DevelopersViewState();
}

class _DevelopersViewState extends State<_DevelopersView> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialDeveloperName != null) {
      _searchController.text = widget.initialDeveloperName!;
      _searchQuery = widget.initialDeveloperName!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopHeader(
        showBack: true,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final allDevs = state.developers;
          final q = _searchQuery.trim().toLowerCase();

          final filtered = allDevs.where((dev) {
            if (q.isEmpty) return true;
            final nameMatch = dev.name.toLowerCase().contains(q);
            final descMatch = dev.description?.toLowerCase().contains(q) ?? false;
            return nameMatch || descMatch;
          }).toList();

          return Column(
            children: [
              // Search Input Container
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن شركة تطوير عقاري...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20, color: AppColors.brandDark),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Developers List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconsaxPlusLinear.buildings, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'لا توجد شركات مطابقة لبحثك'
                                  : 'لا توجد شركات عقارية مضافة حالياً',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.brand,
                        onRefresh: () => context.read<HomeCubit>().load(forceRefresh: true),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final dev = filtered[index];
                            final isExpanded = _expandedIds.contains(dev.id);
                            final compoundCount = state.compounds.where((c) => c.developerName == dev.name).length;

                            return _DeveloperCard(
                              developer: dev,
                              isExpanded: isExpanded,
                              compoundCount: compoundCount,
                              onToggle: () => _toggleExpand(dev.id),
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
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({
    required this.developer,
    required this.isExpanded,
    required this.compoundCount,
    required this.onToggle,
  });

  final Developer developer;
  final bool isExpanded;
  final int compoundCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final hasPhone = developer.phone != null && developer.phone!.trim().isNotEmpty;
    final hasWhatsapp = developer.whatsapp != null && developer.whatsapp!.trim().isNotEmpty;
    final hasDescription = developer.description != null && developer.description!.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECF0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: isExpanded ? 0.08 : 0.03),
            blurRadius: isExpanded ? 16 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Row: Logo, Name, Badges, Downward Arrow Button
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            splashColor: const Color(0xFF101828).withValues(alpha: 0.04),
            highlightColor: const Color(0xFF101828).withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Company Logo (Circular like HomeScreen with BoxFit.cover filling circle)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEAECF0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppNetworkImage(
                      url: developer.logoUrl,
                      fit: BoxFit.cover,
                      placeholder: Center(
                        child: Text(
                          developer.name.isNotEmpty ? developer.name[0] : 'ش',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Company Name & Project count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                developer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101828),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF12B76A),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (compoundCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  IconsaxPlusLinear.buildings_2,
                                  size: 11,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$compoundCount مشروع متاح بالمنصة',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'مطور عقاري معتمد',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Downward Arrow Button (matching FAQ question arrow)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isExpanded ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: const Icon(
                          Icons.expand_more_rounded,
                          size: 22,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content: About & Contact Numbers
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFF2F4F7)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Box: Company Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Text(
                      hasDescription
                          ? developer.description!
                          : 'شركة تطوير عقاري رائدة تقدم مشروعات سكنية واستثمارية متميزة بأعلى معايير الجودة والالتزام التام بمواعيد التسليم.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF344054),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bottom Two Pill Action Buttons ([اتصال] & [واتساب])
                  Row(
                    children: [
                      // Outlined Call Button
                      if (hasPhone) ...[
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Launcher.call(developer.phone!),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF101828),
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFD0D5DD), width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: 18,
                                      color: Color(0xFF111111),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'اتصال',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF101828),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],

                      // Filled WhatsApp Button
                      if (hasWhatsapp || hasPhone)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Launcher.whatsapp(
                                hasWhatsapp ? developer.whatsapp! : developer.phone!,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: Center(
                                child: Transform.translate(
                                  offset: const Offset(6, 0),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      WhatsAppLogo(size: 20, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'واتساب',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        ],
      ),
    );
  }
}
