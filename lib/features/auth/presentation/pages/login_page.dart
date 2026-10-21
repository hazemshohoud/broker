import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../registration/presentation/pages/registration_page.dart';
import '../../../registration/presentation/pages/registration_pending_page.dart';
import '../../../shell/presentation/pages/main_shell.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(
      phone: _phoneController.text.trim(),
      pin: _pinController.text.trim(),
    );
  }

  void _onState(BuildContext context, AuthState state) {
    final destination = switch (state) {
      AuthAdmin() => const AdminDashboardPage(),
      AuthApproved() => const MainShell(),
      AuthPending() => const RegistrationPendingPage(),
      _ => null,
    };
    if (destination != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
      return;
    }
    final message = switch (state) {
      AuthFailure(:final message) || AuthRejected(:final message) => message,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF26262B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE53935)),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: _onState,
          builder: (context, state) {
            final submitting = state is AuthSubmitting;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  AuthHeader(
                    headerImage: Image.asset(
                      'assets/branding/login_logo.png',
                      height: 125,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeSlideIn(
                            duration: const Duration(milliseconds: 450),
                            child: Center(
                              child: Text(
                                'تسجيل الدخول',
                                textAlign: TextAlign.center,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeSlideIn(
                            duration: const Duration(milliseconds: 600),
                            child: AppFormField(
                              label: 'رقم الهاتف',
                              hint: '01xxxxxxxxx',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              prefixWidget: const AppPhoneFieldIcon(),
                              maxLength: 11,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: Validators.egyptianPhone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            duration: const Duration(milliseconds: 750),
                            child: AppPinField(
                              label: 'كلمة المرور',
                              controller: _pinController,
                              textInputAction: TextInputAction.done,
                              validator: Validators.pin,
                            ),
                          ),
                          const SizedBox(height: 28),
                          FadeSlideIn(
                            duration: const Duration(milliseconds: 900),
                            child: AppPrimaryButton(
                              label: 'تسجيل الدخول',
                              loading: submitting,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _OrDivider(),
                          const SizedBox(height: 20),
                          FadeSlideIn(
                            duration: const Duration(milliseconds: 1050),
                            child: OutlinedButton(
                              onPressed: submitting
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegistrationPage(),
                                      ),
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                minimumSize: const Size.fromHeight(54),
                                side: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('إنشاء حساب جديد'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ليس لديك حساب؟',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}
