import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../../onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../registration/presentation/pages/registration_pending_page.dart';
import '../../../shell/presentation/pages/main_shell.dart';
import '../cubit/auth_cubit.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>()..checkSession(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        OnboardingRemoteDataSourceImpl.preloadImages(context);
      }
    });
  }

  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward().whenComplete(_maybeNavigate);

  Animation<double> _interval(double begin, double end, [Curve? curve]) =>
      CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: curve ?? Curves.easeOutCubic),
      );

  late final _trace = _interval(0.04, 0.58, Curves.easeInOutCubic);
  late final _fill = _interval(0.50, 0.76, Curves.easeOutCubic);
  late final _scale = Tween(
    begin: 0.88,
    end: 1.0,
  ).animate(_interval(0.48, 0.80, Curves.easeOutBack));
  late final _glow = _interval(0.35, 0.85, Curves.easeOut);

  /// الوجهة بتتحدد من الـ cubit، والتنقل مستني الأنيميشن يخلص كمان.
  Widget? _destination;

  Future<void> _onAuthState(BuildContext context, AuthState state) async {
    final dest = switch (state) {
      AuthAdmin() => const AdminDashboardPage(),
      AuthApproved() => const MainShell(),
      AuthPending() => const RegistrationPendingPage(),
      AuthNeedsLogin() || AuthFailure() || AuthRejected() => await _getLoginOrOnboarding(),
      _ => null,
    };
    if (!mounted) return;
    _destination = dest;
    _maybeNavigate();
  }

  Future<Widget> _getLoginOrOnboarding() async {
    try {
      final seen = await sl<OnboardingLocalDataSource>().hasSeenOnboarding();
      if (seen) return const LoginPage();
    } catch (_) {}
    return const OnboardingPage();
  }

  void _maybeNavigate() {
    final destination = _destination;
    if (!mounted || destination == null || !_intro.isCompleted) return;
    _destination = null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthState,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, Color(0xFF111111)],
              ),
            ),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (context, _) => Stack(
                alignment: Alignment.center,
                children: [
                  _Glow(intensity: _glow.value),
                  Transform.scale(
                    scale: _scale.value,
                    child: BrandLogo(
                      size: 136,
                      progress: _trace.value,
                      fill: _fill.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// توهج أخضر نيون مركّز ورا اللوجو.
class _Glow extends StatelessWidget {
  const _Glow({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.brand.withValues(alpha: 0.32 * intensity),
              AppColors.brand.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

