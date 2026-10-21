import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../theme/app_colors.dart';
import '../di/injection_container.dart';
import 'brand_logo.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/cubit/notifications_state.dart';
import '../../features/notifications/presentation/widgets/notifications_sheet.dart';

/// الشعار العلوي / الآب بار الموحد في التطبيق بالكامل:
/// - اليمين: أيقونة القائمة (3 خطوط أفقية متدرجة كالمطلوب) أو زر الرجوع
/// - المنتصف: لوجو بروكر المعتمد (السهم الأخضر + الاسم)
/// - اليسار: زر دائري لجرس الإشعارات
class AppTopHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppTopHeader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.avatarUrl,
    this.avatarLetter,
    this.titleBadge,
    this.showBack = false,
    this.onBackTap,
    this.onNotificationTap,
    this.onMenuTap,
    this.trailing,
  });

  /// العنوان الاختياري (يُعرض في الشاشات الفرعية بجوار اللوجو)
  final String? title;

  final String? subtitle;
  final IconData? icon;
  final String? avatarUrl;
  final String? avatarLetter;
  final Widget? titleBadge;

  /// هل يظهر زر الرجوع بدلاً من زر القائمة
  final bool showBack;

  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  void _showNotifications(BuildContext context) {
    NotificationsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final rightButton = showBack
        ? _CircularActionButton(
            icon: IconsaxPlusLinear.arrow_right_3,
            onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
          )
        : const SizedBox(width: 44, height: 44);

    final leftButton = trailing ??
        _CircularBellButton(
          onTap: onNotificationTap ?? () => _showNotifications(context),
        );

    final centerLogo = (showBack && title != null && title!.isNotEmpty)
        ? FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 8),
                const BrandLogo(size: 20, color: AppColors.brand),
              ],
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Image.asset(
              'assets/branding/appbar_logo.png',
              height: 38,
              fit: BoxFit.contain,
            ),
          );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F2F5),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                if (isRtl) ...[
                  rightButton,
                  Expanded(child: Center(child: centerLogo)),
                  leftButton,
                ] else ...[
                  leftButton,
                  Expanded(child: Center(child: centerLogo)),
                  rightButton,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// زر دائري بإطار رمادي ناعم للإجراءات (مثل الرجوع)
class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }
}

/// الزر الدائري لجرس الإشعارات مع شارة عدد الإشعارات غير المقروءة
class _CircularBellButton extends StatelessWidget {
  const _CircularBellButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cubit = sl.isRegistered<NotificationsCubit>() ? sl<NotificationsCubit>() : null;

    return StreamBuilder<NotificationsState>(
      stream: cubit?.stream,
      initialData: cubit?.state,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.unreadCount ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/icons/appbar_bell_icon.png',
                    width: 20,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      IconsaxPlusLinear.notification,
                      size: 20,
                      color: Color(0xFF111111),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand.withValues(alpha: 0.55),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '+9' : '$unreadCount',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


