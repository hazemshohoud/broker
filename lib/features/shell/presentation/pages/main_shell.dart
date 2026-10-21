import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../clients/presentation/pages/clients_page.dart';
import '../../../commissions/presentation/pages/commissions_page.dart';
import '../../../home/presentation/pages/home_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/injection_container.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';

/// الهيكل الرئيسي للتطبيق: تبويبات رئيسية مع كبسولة عائمة زجاجية وأنيميشن فيزيائي مرن
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      sl<NotificationsCubit>().startListening(uid);
    }
  }

  final List<Widget> _pages = const [
    HomePage(),
    ClientsPage(),
    CommissionsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: _pages,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _AnimatedBottomBar(
                selectedIndex: _index,
                onItemSelected: (index) {
                  if (_index != index) {
                    HapticFeedback.selectionClick();
                    setState(() => _index = index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كبسولة البوتوم بار العائمة مع تمويه زجاجي، مؤشر منزلق متمدد فيزيائياً، ونبضات حركية
class _AnimatedBottomBar extends StatefulWidget {
  const _AnimatedBottomBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  State<_AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<_AnimatedBottomBar>
    with TickerProviderStateMixin {
  late int _previousIndex = widget.selectedIndex;
  late int _targetIndex = widget.selectedIndex;

  late final AnimationController _indicatorController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final AnimationController _barBounceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _barScaleAnimation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 1.015)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.015, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 60,
    ),
  ]).animate(_barBounceController);

  double? _lastCalculatedLeft;
  double? _lastCalculatedRight;
  double? _fromLeft;
  double? _fromRight;

  @override
  void initState() {
    super.initState();
    _indicatorController.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _targetIndex = widget.selectedIndex;

      if (_indicatorController.isAnimating &&
          _lastCalculatedLeft != null &&
          _lastCalculatedRight != null) {
        _fromLeft = _lastCalculatedLeft;
        _fromRight = _lastCalculatedRight;
      } else {
        _fromLeft = null;
        _fromRight = null;
      }

      _indicatorController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _barBounceController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _barBounceController.forward(from: 0.0);
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomMargin = (bottomPadding > 0 ? bottomPadding : 14.0) + 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      child: ScaleTransition(
        scale: _barScaleAnimation,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isRtl = Directionality.of(context) == TextDirection.rtl;
                    final totalWidth = constraints.maxWidth;
                    const double inset = 5.0;
                    const double barHeight = 64.0;
                    final indicatorHeight = barHeight - (inset * 2);

                    final contentWidth = totalWidth - (inset * 2);
                    final tabWidth = contentWidth / 4;

                    double getTabLeft(int index) {
                      if (isRtl) {
                        return inset + (3 - index) * tabWidth;
                      } else {
                        return inset + index * tabWidth;
                      }
                    }

                    final initialFromLeft = getTabLeft(_previousIndex);
                    final initialFromRight = initialFromLeft + tabWidth;
                    final toLeft = getTabLeft(_targetIndex);
                    final toRight = toLeft + tabWidth;

                    final effectiveFromLeft = _fromLeft ?? initialFromLeft;
                    final effectiveFromRight = _fromRight ?? initialFromRight;

                    return AnimatedBuilder(
                      animation: _indicatorController,
                      builder: (context, _) {
                        final t = _indicatorController.value;

                        double leftProgress;
                        double rightProgress;

                        if (toLeft > effectiveFromLeft) {
                          // التحرك نحو اليمين: الحافة اليمنى تقود وتتمدد، واليسرى تلحق مع ارتداد
                          rightProgress = const Interval(
                            0.0,
                            0.68,
                            curve: Curves.easeInOutCubic,
                          ).transform(t);
                          leftProgress = const Interval(
                            0.18,
                            1.0,
                            curve: Curves.easeOutBack,
                          ).transform(t);
                        } else if (toLeft < effectiveFromLeft) {
                          // التحرك نحو اليسار: الحافة اليسرى تقود وتتمدد، واليمنى تلحق مع ارتداد
                          leftProgress = const Interval(
                            0.0,
                            0.68,
                            curve: Curves.easeInOutCubic,
                          ).transform(t);
                          rightProgress = const Interval(
                            0.18,
                            1.0,
                            curve: Curves.easeOutBack,
                          ).transform(t);
                        } else {
                          leftProgress = 1.0;
                          rightProgress = 1.0;
                        }

                        final currentLeft = ui.lerpDouble(
                          effectiveFromLeft,
                          toLeft,
                          leftProgress,
                        )!;
                        final currentRight = ui.lerpDouble(
                          effectiveFromRight,
                          toRight,
                          rightProgress,
                        )!;
                        final currentWidth = (currentRight - currentLeft).clamp(
                          tabWidth * 0.7,
                          contentWidth,
                        );

                        _lastCalculatedLeft = currentLeft;
                        _lastCalculatedRight = currentRight;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // كبسولة التحديد الشفافة مع لمسة خضراء أنيقة
                            Positioned(
                              left: currentLeft,
                              top: inset,
                              width: currentWidth,
                              height: indicatorHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.brand.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.brand.withValues(alpha: 0.35),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),

                            // صف عناصر التبويبات الأربعة
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: inset,
                              ),
                              child: SizedBox(
                                height: barHeight,
                                child: Row(
                                  children: [
                                    // 0: الرئيسية
                                    _BottomNavItem(
                                      index: 0,
                                      label: 'الرئيسية',
                                      isSelected: widget.selectedIndex == 0,
                                      unselectedIcon: const ImageIcon(
                                        AssetImage('assets/icons/nav_home.png'),
                                        key: ValueKey('home_unselected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      selectedIcon: const ImageIcon(
                                        AssetImage('assets/icons/nav_home_selected.png'),
                                        key: ValueKey('home_selected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      onTap: () => _onItemTapped(0),
                                    ),

                                    // 1: العملاء
                                    _BottomNavItem(
                                      index: 1,
                                      label: 'العملاء',
                                      isSelected: widget.selectedIndex == 1,
                                      unselectedIcon: const Icon(
                                        IconsaxPlusLinear.user,
                                        key: ValueKey('clients_unselected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      selectedIcon: const Icon(
                                        IconsaxPlusBold.user,
                                        key: ValueKey('clients_selected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      onTap: () => _onItemTapped(1),
                                    ),

                                    // 2: عمولاتي
                                    _BottomNavItem(
                                      index: 2,
                                      label: 'عمولاتي',
                                      isSelected: widget.selectedIndex == 2,
                                      unselectedIcon: const Icon(
                                        IconsaxPlusLinear.wallet_money,
                                        key: ValueKey('commissions_unselected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      selectedIcon: const Icon(
                                        IconsaxPlusBold.wallet_money,
                                        key: ValueKey('commissions_selected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      onTap: () => _onItemTapped(2),
                                    ),

                                    // 3: حسابي
                                    _BottomNavItem(
                                      index: 3,
                                      label: 'حسابي',
                                      isSelected: widget.selectedIndex == 3,
                                      unselectedIcon: const ImageIcon(
                                        AssetImage('assets/icons/nav_account.png'),
                                        key: ValueKey('account_unselected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      selectedIcon: const ImageIcon(
                                        AssetImage('assets/icons/nav_account_selected.png'),
                                        key: ValueKey('account_selected'),
                                        size: 22,
                                        color: Color(0xFF111111),
                                      ),
                                      onTap: () => _onItemTapped(3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isSelected;
  final Widget unselectedIcon;
  final Widget selectedIcon;
  final VoidCallback onTap;

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _scaleAnimation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 1.2)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.2, end: 0.95)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.95, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 30,
    ),
  ]).animate(_popController);

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) {
      _popController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSelected && widget.isSelected) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _popController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // حاوية الأيقونة بمقاس ثابت ونبضة Scale Pop من المركز دون إزاحة للنص
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      final scale =
                          widget.isSelected ? _scaleAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: widget.isSelected
                              ? widget.selectedIcon
                              : widget.unselectedIcon,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // النص ثابت دائماً أسفل الأيقونة، يتغير وزنه فقط من Medium إلى Bold
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF111111),
                    height: 1.2,
                    fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

