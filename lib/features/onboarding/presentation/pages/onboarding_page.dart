import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/datasources/onboarding_local_data_source.dart';
import '../../data/datasources/onboarding_remote_data_source.dart';
import '../../domain/entities/onboarding_item.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.destination,
  });

  /// الوجهة بعد انتهاء أو تخطي شاشات الترحيب (الافتراضي: صفحة تسجيل الدخول)
  final Widget? destination;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final OnboardingRemoteDataSource _dataSource = OnboardingRemoteDataSourceImpl();

  late final PageController _pageController;
  late final AnimationController _progressController;

  List<OnboardingItem> _items = OnboardingRemoteDataSourceImpl.cachedOrDefaults;
  int _currentIndex = 0;

  /// مدة كل شريحة (4.5 ثانية لكل صورة)
  static const Duration _slideDuration = Duration(milliseconds: 4500);

  @override
  void initState() {
    super.initState();
    const OnboardingLocalDataSourceImpl().setOnboardingSeen();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    )..addStatusListener(_onProgressStatus);

    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _dataSource.getOnboardingItems();
    if (!mounted) return;
    setState(() {
      _items = items.isNotEmpty ? items : OnboardingItem.defaults;
    });
    _progressController.forward(from: 0.0);
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_currentIndex < _items.length - 1) {
        _goToIndex(_currentIndex + 1);
      } else {
        // عند اكتمال الشرائح الأربعة ينتقل تلقائياً لصفحة تسجيل الدخول
        _finish();
      }
    }
  }

  void _goToIndex(int index) {
    if (index < 0 || index >= _items.length) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    _progressController.forward(from: 0.0);
  }

  void _finish() {
    _progressController.stop();
    const OnboardingLocalDataSourceImpl().setOnboardingSeen();
    if (!mounted) return;
    final dest = widget.destination ?? const LoginPage();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => dest,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    // في الواجهة العربية (RTL):
    // النقر على الثلث الأيسر (أمام) ينقل للشريحة التالية أو ينهي الأونبوردنج
    // النقر على الثلث الأيمن (خلف) يعود للشريحة السابقة
    if (tapX < screenWidth * 0.35) {
      if (_currentIndex < _items.length - 1) {
        _goToIndex(_currentIndex + 1);
      } else {
        _finish();
      }
    } else if (tapX > screenWidth * 0.65) {
      if (_currentIndex > 0) {
        _goToIndex(_currentIndex - 1);
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final currentItem = _items.isNotEmpty
        ? _items[_currentIndex.clamp(0, _items.length - 1)]
        : OnboardingItem.defaults[0];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onLongPressStart: (_) => _progressController.stop(),
            onLongPressEnd: (_) => _progressController.forward(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. صور الشرائح وخلفياتها
                PageView.builder(
                  controller: _pageController,
                  physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                  onPageChanged: (index) {
                    if (_currentIndex != index) {
                      setState(() => _currentIndex = index);
                      _progressController.forward(from: 0.0);
                    }
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return RepaintBoundary(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppNetworkImage(
                            url: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: ColoredBox(
                              color: const Color(0xFF111827),
                              child: Center(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // تدرج علوي لتوضيح أشرطة التقدم والشعار
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 190,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.85),
                                    Colors.black.withValues(alpha: 0.40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // تدرج سفلي داكن لقراءة النصوص والزرار بكل وضوح
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 380,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.95),
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 2. الهيدر العلوي: شريط التقدم المجزأ فقط (تمت إزالة اللوجو والاسم بالكامل)
                Positioned(
                  top: topPadding + 12,
                  left: 16,
                  right: 16,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return _SegmentedProgressBar(
                        count: _items.length,
                        currentIndex: _currentIndex,
                        progress: _progressController.value,
                      );
                    },
                  ),
                ),

                // 3. المحتوى السفلي: العنوان والوصف وزر "ابدأ الآن" ثابت من أول صورة للأخيرة
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 26,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.15),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey<int>(_currentIndex),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentItem.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // زر "ابدأ الآن" متواجد دائماً من أول صورة للأخيرة بدون أي أيقونة
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _finish();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: AppColors.primaryDark,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
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

/// البروجرس بار المقسم لـ 4 أجزاء متساوية مع ملء تدريجي سلس (Stories Style)
class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({
    required this.count,
    required this.currentIndex,
    required this.progress,
  });

  final int count;
  final int currentIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        double itemProgress;
        if (index < currentIndex) {
          itemProgress = 1.0;
        } else if (index == currentIndex) {
          itemProgress = progress.clamp(0.0, 1.0);
        } else {
          itemProgress = 0.0;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == count - 1 ? 0.0 : 6.0,
            ),
            child: Container(
              height: 3.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: itemProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.45),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
