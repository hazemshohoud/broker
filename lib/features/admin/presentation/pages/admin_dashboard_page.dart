import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../auth/presentation/pages/login_page.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/admin_grant_commission_sheet.dart';
import '../widgets/admin_send_notification_sheet.dart';
import 'admin_commissions_page.dart';
import 'admin_compounds_page.dart';
import 'admin_developers_page.dart';
import 'admin_filter_options_page.dart';
import 'admin_onboarding_page.dart';
import 'admin_registrations_page.dart';
import 'admin_viewing_requests_page.dart';
import 'admin_withdrawals_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadDashboard(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _signOutAdmin(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لوحة تحكم الإدارة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'إدارة بيانات التطبيق والوسطاء والصفقات',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsetsDirectional.only(end: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.brand.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(IconsaxPlusBold.shield_security, size: 14, color: AppColors.brandDark),
                  SizedBox(width: 4),
                  Text(
                    'المشرف',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.favorite,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              color: AppColors.brand,
              onRefresh: () => context.read<AdminCubit>().loadDashboard(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Quick Summary Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatMetricCard(
                          title: 'طلبات الانضمام',
                          value: '${state.pendingRegistrationsCount}',
                          subtitle: 'قيد المراجعة',
                          icon: IconsaxPlusBold.profile_add,
                          isHighlight: state.pendingRegistrationsCount > 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminRegistrationsPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatMetricCard(
                          title: 'طلبات السحب',
                          value: '${state.pendingWithdrawalsCount}',
                          subtitle: 'تحتاج تحويل',
                          icon: IconsaxPlusBold.card_receive,
                          isHighlight: state.pendingWithdrawalsCount > 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminWithdrawalsPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMetricCard(
                          title: 'الكمبوندات',
                          value: '${state.compounds.length}',
                          subtitle: 'كمبوند معروض',
                          icon: IconsaxPlusBold.building_4,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminCompoundsPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatMetricCard(
                          title: 'المطورين',
                          value: '${state.developers.length}',
                          subtitle: 'شركة عقارية',
                          icon: IconsaxPlusBold.buildings,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminDevelopersPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMetricCard(
                          title: 'طلبات المعاينة',
                          value: '${state.pendingViewingRequestsCount}',
                          subtitle: 'قيد المراجعة',
                          icon: IconsaxPlusBold.calendar_1,
                          isHighlight: state.pendingViewingRequestsCount > 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminViewingRequestsPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatMetricCard(
                          title: 'العمولات المعلقة',
                          value: '${state.pendingCommissionsCount}',
                          subtitle: 'تحتاج اعتماد',
                          icon: IconsaxPlusBold.wallet_check,
                          isHighlight: state.pendingCommissionsCount > 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AdminCubit>(),
                                child: const AdminCommissionsPage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'أقسام الإدارة والتحكم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Module Items
                  _AdminModuleTile(
                    title: 'توثيق وقبول الوسطاء',
                    subtitle: 'مراجعة بيانات المنضمين الجدد، تدقيق المستندات وتفعيل الحسابات',
                    icon: IconsaxPlusBold.user_cirlce_add,
                    badgeCount: state.pendingRegistrationsCount,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminRegistrationsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'إدارة الكمبوندات',
                    subtitle: 'إضافة كمبوند جديد، رفع الصور، تحديد الأسعار والعمولات والتفاصيل',
                    icon: IconsaxPlusBold.building_4,
                    badgeText: '${state.compounds.length} مشروع',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminCompoundsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'المطورين العقاريين',
                    subtitle: 'إضافة شركات التطوير وشعاراتها والترتيب المعروض في الهوم',
                    icon: IconsaxPlusBold.buildings,
                    badgeText: '${state.developers.length} مطور',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminDevelopersPage(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'طلبات سحب العمولات',
                    subtitle: 'مراجعة طلبات السحب للوسطاء وتأكيد التحويلات عبر إنستاباي والمحافظ',
                    icon: IconsaxPlusBold.card_receive,
                    badgeCount: state.pendingWithdrawalsCount,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminWithdrawalsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'طلبات المعاينة',
                    subtitle: 'مراجعة طلبات المعاينة الواردة من الوسطاء والتأكيد والتواصل مع العملاء',
                    icon: IconsaxPlusBold.calendar_1,
                    badgeCount: state.pendingViewingRequestsCount,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminViewingRequestsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'سجل العمولات والاعتماد',
                    subtitle: 'مراجعة العمولات وتغيير حالتها من قيد الاعتماد إلى معتمدة وتأكيد الصرف',
                    icon: IconsaxPlusBold.wallet_check,
                    badgeCount: state.pendingCommissionsCount,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminCommissionsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'إسناد عمولة لوسيط',
                    subtitle: 'إضافة عمولة جديدة لحساب وسيط بعد إتمام بيع ناجح',
                    icon: IconsaxPlusBold.money_add,
                    onTap: () => AdminGrantCommissionSheet.show(
                      context,
                      cubit: context.read<AdminCubit>(),
                      registrations: state.registrations,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'إرسال إشعار فوري للوسطاء',
                    subtitle: 'إرسال تنبيه أو إشعار لوسيط محدد أو لجميع الوسطاء يظهر في الجرس',
                    icon: IconsaxPlusBold.notification_bing,
                    onTap: () => AdminSendNotificationSheet.show(
                      context,
                      cubit: context.read<AdminCubit>(),
                      registrations: state.registrations,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'خيارات التصفية والمناطق',
                    subtitle: 'تعديل المحافظات والمراكز والأحياء، وأنواع الوحدات وحالات الاستلام',
                    icon: IconsaxPlusBold.filter_edit,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AdminCubit>(),
                          child: const AdminFilterOptionsPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AdminModuleTile(
                    title: 'شاشات الترحيب (Onboarding)',
                    subtitle: 'إدارة صور ونصوص الشاشات الترحيبية الأربعة المعروضة للوسطاء الجدد',
                    icon: IconsaxPlusBold.gallery,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminOnboardingPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AdminModuleTile(
                    title: 'تسجيل الخروج من الإدارة',
                    subtitle: 'إنهاء الجلسة والعودة لشاشة الدخول وقفل لوحة التحكم نهائياً',
                    icon: IconsaxPlusBold.logout,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: const Color(0xFFFEF2F2),
                    titleColor: const Color(0xFFEF4444),
                    onTap: () => _signOutAdmin(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Future<void> _signOutAdmin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج من الإدارة'),
        content: const Text(
          'هل ترغب في إنهاء جلسة الإدارة والعودة لشاشة تسجيل الدخول؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تسجيل خروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}

class _StatMetricCard extends StatelessWidget {
  const _StatMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isHighlight = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlight ? AppColors.brandDark.withValues(alpha: 0.4) : AppColors.border,
              width: isHighlight ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isHighlight
                          ? AppColors.brand.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isHighlight ? AppColors.brandDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isHighlight ? AppColors.brandDark : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminModuleTile extends StatelessWidget {
  const _AdminModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeText,
    this.iconColor,
    this.iconBgColor,
    this.titleColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final String? badgeText;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.brandDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: titleColor ?? AppColors.textPrimary,
                          ),
                        ),
                        if (badgeCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECDCA)),
                            ),
                            child: Text(
                              '$badgeCount جديد',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB42318),
                              ),
                            ),
                          ),
                        ] else if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                IconsaxPlusLinear.arrow_left_2,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
