import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../auth/presentation/widgets/auth_header.dart';
import '../../domain/entities/registration_request.dart';
import '../cubit/registration_cubit.dart';
import '../widgets/basic_info_step.dart';
import '../widgets/payout_methods_step.dart';
import '../widgets/step_indicator.dart';
import '../widgets/terms_step.dart';
import 'registration_pending_page.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegistrationCubit>(),
      child: const _RegistrationView(),
    );
  }
}

class _RegistrationView extends StatefulWidget {
  const _RegistrationView();

  @override
  State<_RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<_RegistrationView> {
  final _pageController = PageController();
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  final _instaPayController = TextEditingController();
  final _walletController = TextEditingController();

  int _step = 0;
  DateTime? _birthDate;
  XFile? _photo;
  bool _termsAccepted = false;
  bool _payoutError = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in [
      _nameController,
      _phoneController,
      _whatsappController,
      _pinController,
      _pinConfirmController,
      _instaPayController,
      _walletController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        return _formKeys[0].currentState!.validate();
      case 1:
        final formValid = _formKeys[1].currentState?.validate() ?? true;
        final hasMethod =
            _instaPayController.text.trim().isNotEmpty ||
            _walletController.text.trim().isNotEmpty;
        setState(() => _payoutError = !hasMethod);
        return formValid && hasMethod;
      default:
        return _termsAccepted;
    }
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_step == 2) {
      _submit();
      return;
    }
    setState(() => _step++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _submit() {
    context.read<RegistrationCubit>().submit(
      RegistrationRequest(
        fullName: _nameController.text.trim(),
        birthDate: _birthDate!,
        governorate: defaultGovernorate,
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        pin: _pinController.text.trim(),
        instaPayNumber: _emptyToNull(_instaPayController.text),
        walletNumber: _emptyToNull(_walletController.text),
        photoPath: _photo?.path,
      ),
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static const _stepSubtitles = [
    'الخطوة 1 من 3 · البيانات الأساسية',
    'الخطوة 2 من 3 · طرق استلام العمولات',
    'الخطوة 3 من 3 · الشروط والأحكام',
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocConsumer<RegistrationCubit, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const RegistrationPendingPage(),
                ),
              );
            } else if (state is RegistrationFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
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
          },
          builder: (context, state) {
            final submitting = state is RegistrationSubmitting;
            return PopScope(
              canPop: _step == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                if (_step > 0) _previous();
              },
              child: Column(
                children: [
                  AuthHeader(
                    compact: true,
                    title: 'إنشاء حساب',
                    subtitle: _stepSubtitles[_step],
                    onBackPressed: () {
                      if (_step > 0) {
                        _previous();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                  child: StepIndicator(currentStep: _step),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BasicInfoStep(
                        formKey: _formKeys[0],
                        nameController: _nameController,
                        phoneController: _phoneController,
                        whatsappController: _whatsappController,
                        pinController: _pinController,
                        pinConfirmController: _pinConfirmController,
                        birthDate: _birthDate,
                        onBirthDateChanged: (date) =>
                            setState(() => _birthDate = date),
                        photo: _photo,
                        onPhotoChanged: (photo) =>
                            setState(() => _photo = photo),
                      ),
                      PayoutMethodsStep(
                        formKey: _formKeys[1],
                        instaPayController: _instaPayController,
                        walletController: _walletController,
                        showMissingMethodError: _payoutError,
                      ),
                      TermsStep(
                        accepted: _termsAccepted,
                        onAcceptedChanged: (value) =>
                            setState(() => _termsAccepted = value),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_step > 0) ...[
                          OutlinedButton(
                            onPressed: submitting ? null : _previous,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              minimumSize: const Size(96, 54),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('السابق'),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: AppPrimaryButton(
                            label: _step == 2 ? 'إنشاء الحساب' : 'التالي',
                            loading: submitting,
                            onPressed: _next,
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
